# --
# Copyright (C) 2012 - 2018 Perl-Services.de, http://perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Ticket::Article::Backend::MIMEBase::ArticleStorageTSALFS;

use strict;
use warnings;

use Data::Dumper;
use File::Find;
use File::Basename;

use parent qw(Kernel::System::Ticket::Article::Backend::MIMEBase::ArticleStorageFS);

our @ObjectDependencies = qw(
    Kernel::System::Ticket
    Kernel::System::Log
    Kernel::Config
    Kernel::System::DB
    Kernel::System::Main
);

sub AttachmentExists {
    my ($Self, %Param) = @_;

    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
    
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

    my $ContentPath = $Self->_ArticleContentPathGet( ArticleID => $Param{ArticleID} );
    my $Path = "$Self->{ArticleDataDir}/$ContentPath/$Param{ArticleID}/$Param{Filename}";

    return 1 if -f $Path;
    return;
}

sub AttachmentRename {
    my ($Self, %Param) = @_;

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');
    my $DBObject     = $Kernel::OM->Get('Kernel::System::DB');
    my $MainObject   = $Kernel::OM->Get('Kernel::System::Main');
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

    $Param{Filename} = $MainObject->FilenameCleanUp(
        Filename => $Param{Filename},
        Type     => 'Local',
    );

    my $AttachmentExists = $Self->AttachmentExists( %Param );

    if ( $Debug && $AttachmentExists ) {
        $LogObject->Log(
            Priority => 'debug',
            Message  => "Attachment exists",
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
            Priority => 'debug',
            Message  => ( sprintf "Rename ID %s // File %s",
                $AttachmentID // '', $Filename // '' ),
        );
    }

    return if !$AttachmentID;
    return if !$Filename;

    my $ContentPath = $Self->_ArticleContentPathGet( ArticleID => $Param{ArticleID} );
    my $Path = "$Self->{ArticleDataDir}/$ContentPath/$Param{ArticleID}";

    if ( $Debug ) {
        $LogObject->Log(
            Priority => 'debug',
            Message  => "Path: $Path",
        );
    }

    if ( -e $Path ) {
        my @List = $MainObject->DirectoryRead(
            Directory => $Path,
            Filter    => "*",
        );

        FILE:
        for my $File (@List) {

            if ( $Debug ) {
                $LogObject->Log(
                    Priority => 'debug',
                    Message  => "Try $File // $Filename -> $Param{Filename}",
                );
            }

            next FILE if $File !~ m{ / \Q$Filename\E (?:\.content_ (?:type|alternative|id) | \.disposition)? \z}xms;

            (my $NewPath = $File) =~ s{
                \Q$Filename\E
                (
                    \.content_ (?:type|alternative|id) |
                    \.disposition
                )?
                \z
            }{$Param{Filename} . ($1 // '')}exms;

            if ( $Debug ) {
                $LogObject->Log(
                    Priority => 'debug',
                    Message  => "Old: $File // New: $NewPath",
                );
            }

            if ( !rename $File, $NewPath ) {
                $LogObject->Log(
                    Priority => 'error',
                    Message  => "Can't rename: $File to $Param{Filename}: $!!",
                );
            }
        }
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

    # rename attachment in filesystem
    # return if only delete in my backend
    return 1 if $Param{OnlyMyBackend};

    # rename attachment in database
    return if !$DBObject->Do(
        SQL  => 'UPDATE article_data_mime_attachment SET filename = ? WHERE article_id = ? AND id = ?',
        Bind => [ \$Param{Filename}, \$Param{ArticleID}, \$AttachmentID ],
    );

    return 1;
}

sub ArticleDeleteSingleAttachment {
    my ($Self, %Param) = @_;
    
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');
    my $DBObject     = $Kernel::OM->Get('Kernel::System::DB');
    my $MainObject   = $Kernel::OM->Get('Kernel::System::Main');
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

    # delete from fs
    my $ContentPath = $Self->_ArticleContentPathGet( ArticleID => $Param{ArticleID} );
    my $Path = "$Self->{ArticleDataDir}/$ContentPath/$Param{ArticleID}";
    if ( -e $Path ) {
        my @List = $MainObject->DirectoryRead(
            Directory => $Path,
            Filter    => "*",
            Silent    => 1,
        );

        FILE:
        for my $File (@List) {

            next FILE if $File !~ m{ / \Q$Filename\E (?: \.content_ (?:type|alternative|id) | \.disposition )? \z }xms;
            next FILE if $File =~ m{ / plain\.txt $ }xms;
            next FILE if $File =~ m{ /file-[12] $ }xms;

            if ( !unlink "$File" ) {
                $LogObject->Log(
                    Priority => 'error',
                    Message  => "Can't remove: $File: $!!",
                );
            }
        }
    }

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

    # return if only delete in my backend
    return 1 if $Param{OnlyMyBackend};

    # delete attachments from db
    return if !$DBObject->Do(
        SQL  => 'DELETE FROM article_data_mime_attachment WHERE article_id = ? AND id = ?',
        Bind => [
            \$Param{ArticleID},
            \$AttachmentID,
        ],
    );

    return 1;
}

sub AttachmentInfoGet {
    my ($Self, %Param) = @_;

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $MainObject   = $Kernel::OM->Get('Kernel::System::Main');
    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');
    my $UtilsObject  = $Kernel::OM->Get('Kernel::System::TicketAttachments::Utils');

    my $Debug = $ConfigObject->Get( 'Attachmentlist::Debug' );
    
    my $AttachmentID = 0;
    my $Filename;
    my $Filesize;

    my $ContentPath = $Self->_ArticleContentPathGet( ArticleID => $Param{ArticleID} );
    my $Path = "$Self->{ArticleDataDir}/$ContentPath/$Param{ArticleID}";

    my $FilenameToCheck = basename( $Param{Filename} // '' );

    if ( $Debug ) {
        $LogObject->Log(
            Priority => 'debug',
            Message  => $MainObject->Dump( \%Param ),
        );
    }

    if ( $Debug ) {
        $LogObject->Log(
            Priority => 'debug',
            Message  => $MainObject->Dump( [ $Path, $FilenameToCheck ] ),
        );
    }

    if ( -e $Path ) {
        my @List = $MainObject->DirectoryRead(
            Directory => $Path,
            Filter    => "*",
            Silent    => 1,
        );

        FILE:
        for my $File ( sort @List ) {

            if ( $Debug ) {
                $LogObject->Log(
                    Priority => 'debug',
                    Message  => "File: $File",
                );
            }

            next FILE if $File =~ m{ (?: \.content_ (?:alternative|type|id) | \.disposition ) $}xms;
            next FILE if $File =~ m{/plain\.txt$};

            next FILE if !-e "$File.content_type";

            if ( $File =~ m{/file-2$}xms ) {
                $AttachmentID++;
            }

            next FILE if $File =~ m{/file-[12]$}xms;

            my %TmpInfo;
            my $ContentType = $MainObject->FileRead(
                Location => "$File.content_type",
            );

            next FILE if !$ContentType;

            $TmpInfo{ContentType} = ${$ContentType};

            if ( -e "$File.content_id" ) {
                my $ContentID = $MainObject->FileRead(
                    Location => "$File.content_id",
                );

                $TmpInfo{ContentID} = ${$ContentID};
            }

            if ( -e "$File.disposition" ) {
                my $Disposition = $MainObject->FileRead(
                    Location => "$File.disposition",
                );

                $TmpInfo{Disposition} = ${$Disposition};
            }

            if ( $Debug ) {
                $LogObject->Log(
                    Priority => 'debug',
                    Message  => $MainObject->Dump( \%TmpInfo ),
                );
            }

            next FILE if $TmpInfo{Disposition} && 'inline' eq lc $TmpInfo{Disposition};
            next FILE if $TmpInfo{ContentID} && $TmpInfo{ContentType} =~ m{image}ixms;

            $Filesize = -s $File;

            $File =~ s{^.*/}{};

            $Filename = $File;
            $AttachmentID++;

            if ( $Debug ) {
                $LogObject->Log(
                    Priority => 'debug',
                    Message  => $MainObject->Dump( [ $Filename, $AttachmentID ] ),
                );
            }

            if ( $Param{FileID} && $Param{FileID} == $AttachmentID ) {
                last FILE;
            }
            elsif ( $FilenameToCheck && $FilenameToCheck eq basename($File) ) {
                last FILE;
            }
        }
    }

    if ( $Debug ) {
        $LogObject->Log(
            Priority => 'debug',
            Message  => ( sprintf "Filename: %s // Filesize: %s",
                $Filename // '', $Filesize // '' ),
        );
    }

    return if !$AttachmentID;
    return if !$Filename;

    my $Size = $UtilsObject->FormatSize( $Filesize || 0 );

    if ( $Debug ) {
        $LogObject->Log(
            Priority => 'debug',
            Message  => "Size: $Size // $Filesize",
        );
    }

    return ($AttachmentID, $Filename, $Size);
}

1;
