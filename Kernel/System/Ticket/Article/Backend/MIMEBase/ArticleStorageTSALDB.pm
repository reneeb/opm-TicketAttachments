# --
# Copyright (C) 2012 - 2018 Perl-Services.de, http://perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Ticket::Article::Backend::MIMEBase::ArticleStorageTSALDB;

use strict;
use warnings;

use MIME::Base64;

use parent qw(Kernel::System::Ticket::Article::Backend::MIMEBase::ArticleStorageDB);

our @ObjectDependencies = qw(
    Kernel::System::Ticket
    Kernel::System::Log
    Kernel::Config
    Kernel::System::DB
    Kernel::System::Main
);

sub AttachmentExists {
    my ($Self, %Param) = @_;

    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');
    my $DBObject     = $Kernel::OM->Get('Kernel::System::DB');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    
    my $Debug = $ConfigObject->Get( 'Attachmentlist::Debug' );

    # check needed stuff
    for my $Needed (qw(ArticleID Filename)) {
        if ( !$Param{$Needed} ) {
            $LogObject->Log(
                Priority => 'error',
                Message => "Need $Needed!",
            );
            return;
        }
    }

    # check if attachment already exists
    return if !$DBObject->Prepare(
        SQL   => 'SELECT id FROM article_data_mime_attachment WHERE article_id = ? AND filename = ?',
        Bind  => [ \$Param{ArticleID}, \$Param{Filename} ],
        Limit => 1,
    );

    my $ID;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $ID = $Row[0];
    }

    if ( $Debug ) {
        $LogObject->Log(
            Priority => 'notice',
            Message  => "ID: " . ($ID || ''),
        );
    }

    return if !$ID;

    return 1;
}

sub AttachmentRename {
    my ($Self, %Param) = @_;

    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');
    my $DBObject     = $Kernel::OM->Get('Kernel::System::DB');
    my $MainObject   = $Kernel::OM->Get('Kernel::System::Main');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    
    # check needed stuff
    for my $Needed (qw(ArticleID UserID FileID TicketID Filename)) {
        if ( !$Param{$Needed} ) {
            $LogObject->Log(
                Priority => 'error',
                Message => "Need $Needed!",
            );
            return;
        }
    }

    my $Debug = $ConfigObject->Get( 'Attachmentlist::Debug' );

    if ( $Debug ) {
        $LogObject->Log(
            Priority => 'notice',
            Message  => join ' // ', map{ join ' => ', $_, $Param{$_} }keys %Param,
        );
    }

    $Param{Filename} = $MainObject->FilenameCleanUp(
        Filename => $Param{Filename},
        Type     => 'Local',
    );

    my $AttachmentExists = $Self->AttachmentExists( %Param );

    if ( $Debug ) {
        $LogObject->Log(
            Priority => 'notice',
            Message  => "Attachment exists: $AttachmentExists",
        );
    }

    if ( $AttachmentExists && !$Param{Force} ) {
        $LogObject->Log(
            Priority => 'error',
            Message => "Attachment already exists!",
        );

        return;
    }

    my ($AttachmentID, $Filename) = $Self->AttachmentInfoGet( %Param );

    if ( $Debug ) {
        $LogObject->Log(
            Priority => 'notice',
            Message  => "AttachmentID: $AttachmentID, Filename $Filename",,
        );
    }

    return if !$AttachmentID;
    return if !$Filename;

    # rename attachment in database
    return if !$DBObject->Do(
        SQL  => 'UPDATE article_data_mime_attachment SET filename = ? WHERE article_id = ? AND id = ?',
        Bind => [ \$Param{Filename}, \$Param{ArticleID}, \$AttachmentID ],
    );

    if ( $Debug ) {
        $LogObject->Log(
            Priority => 'notice',
            Message  => "renamed attachment",
        );
    }

    # add history entry
    $TicketObject->HistoryAdd(
        TicketID     => $Param{TicketID},
        ArticleID    => $Param{ArticleID},
        HistoryType  => 'AttachmentRename',
        Name         => "\%\%$Filename\%\%$Param{Filename}",
        CreateUserID => $Param{UserID},
    );

    $TicketObject->EventHandler(
        Event => 'AttachmentRename',
        Data  => {
            ArticleID => $Param{ArticleID},
            FileID    => $AttachmentID,
            Filename  => $Filename,
            TicketID  => $Param{TicketID},
        },
        UserID => $Param{UserID},
    );

    # return of only delete in my backend
    return 1 if $Param{OnlyMyBackend};

    # rename attachment in filesystem
    my $ContentPath = $Self->_ArticleContentPathGet( ArticleID => $Param{ArticleID} );
    my $Path = "$Self->{ArticleDataDir}/$ContentPath/$Param{ArticleID}";
    if ( -e $Path ) {
        my @List = $MainObject->DirectoryRead(
            Directory => $Path,
            Filter    => "*",
        );

        FILE:
        for my $File (@List) {

            next FILE if $File !~ m{ / \Q$Filename\E (?:\.content_(?:type|alternative|id) | \.disposition)? \z }xms;
            next FILE if $File =~ m{/plain.txt$};
            next FILE if $File =~ m{/file-[12]$};

            (my $NewPath = $File) =~ s{ \Q$Filename\E (\.content_(?:type|alternative|id))? \z }{$Param{Filename}$1}xms;

            if ( !rename $File, $NewPath ) {
                $LogObject->Log(
                    Priority => 'error',
                    Message  => "Can't rename: $File to $Param{Filename}: $!!",
                );
            }
        }
    }

    return 1;
}

sub ArticleDeleteSingleAttachment {
    my ($Self, %Param) = @_;
    
    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');
    my $DBObject     = $Kernel::OM->Get('Kernel::System::DB');
    my $MainObject   = $Kernel::OM->Get('Kernel::System::Main');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    
    # check needed stuff
    for my $Needed (qw(ArticleID UserID FileID TicketID)) {
        if ( !$Param{$Needed} ) {
            $LogObject->Log(
                Priority => 'error',
                Message => "Need $Needed!",
            );
            return;
        }
    }

    my ($AttachmentID, $Filename) = $Self->AttachmentInfoGet( %Param );

    return if !$AttachmentID;
    return if !$Filename;

    # delete attachments
    return if !$DBObject->Do(
        SQL  => 'DELETE FROM article_data_mime_attachment WHERE article_id = ? AND id = ?',
        Bind => [
            \$Param{ArticleID},
            \$AttachmentID,
        ],
    );

    # add history entry
    $TicketObject->HistoryAdd(
        TicketID     => $Param{TicketID},
        ArticleID    => $Param{ArticleID},
        HistoryType  => 'AttachmentDelete',
        Name         => "\%\%$Filename",
        CreateUserID => $Param{UserID},
    );

    # trigger event
    $TicketObject->EventHandler(
        Event => 'SingleTicketAttachmentDelete',
        Data  => {
            ArticleID => $Param{ArticleID},
            FileID    => $AttachmentID,
            Filename  => $Filename,
            TicketID  => $Param{TicketID},
        },
        UserID => $Param{UserID},
    );

    # return of only delete in my backend
    return 1 if $Param{OnlyMyBackend};

    # delete from fs
    my $ContentPath = $Self->_ArticleContentPathGet( ArticleID => $Param{ArticleID} );
    my $Path = "$Self->{ArticleDataDir}/$ContentPath/$Param{ArticleID}";
    if ( -e $Path ) {
        my @List = $MainObject->DirectoryRead(
            Directory => $Path,
            Filter    => "*",
        );

        FILE:
        for my $File (@List) {

            next FILE if $File !~ m{ / \Q$Filename\E (?: \.content_ (?:type|alternative|id) | \.disposition )? \z }xms;
            next FILE if $File =~ m{/plain.txt$};
            next FILE if $File =~ m{/file-[12]$};

            if ( !unlink $File ) {
                $LogObject->Log(
                    Priority => 'error',
                    Message  => "Can't remove: $File: $!!",
                );
            }
        }
    }

    return 1;
}

sub AttachmentInfoGet {
    my ($Self, %Param) = @_;

    my $DBObject    = $Kernel::OM->Get('Kernel::System::DB');
    my $UtilsObject = $Kernel::OM->Get('Kernel::System::TicketAttachments::Utils');
    
    # try database
    return if !$DBObject->Prepare(
        SQL => 'SELECT id, filename, content_size FROM article_data_mime_attachment WHERE article_id = ? ORDER BY filename, id',
        Bind   => [ \$Param{ArticleID} ],
        Limit  => $Param{FileID},
    );

    my $AttachmentID;
    my $Filename;
    my $Size;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $AttachmentID = $Row[0];
        $Filename     = $Row[1];
        $Size         = $Row[2];
    }

    return if !$AttachmentID;
    return if !$Filename;

    $Size = $UtilsObject->FormatSize( $Size );

    return ($AttachmentID, $Filename, $Size);
}

1;
