# --
# Copyright (C) 2011 - 2023 Perl-Services.de, https://www.perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::TicketZoom::Attachmentlist;

use strict;
use warnings;

use List::Util qw(first);

our @ObjectDependencies = qw(
    Kernel::Config
    Kernel::System::Encode
    Kernel::System::Log
    Kernel::System::Main
    Kernel::System::DB
    Kernel::System::Time
    Kernel::System::Web::Request
    Kernel::Output::HTML::Layout
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{UserID} = $Param{UserID};

    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    $Self->{CompareMethod} = $ConfigObject->Get('Attachmentlist::ExcludeMethod') || 'string_match';

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ConfigObject  = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject  = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject   = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $TicketObject  = $Kernel::OM->Get('Kernel::System::Ticket');
    my $UtilsObject   = $Kernel::OM->Get('Kernel::System::TicketAttachments::Utils');
    my $ArticleObject = $Kernel::OM->Get('Kernel::System::Ticket::Article');
    my $MainObject    = $Kernel::OM->Get('Kernel::System::Main');
    my $LogObject     = $Kernel::OM->Get('Kernel::System::Log');

    # define if rich text should be used
    $Self->{RichText}
        = $ConfigObject->Get('Ticket::Frontend::ZoomRichTextForce')
        || $LayoutObject->{BrowserRichText}
        || 0;

    # strip html and ascii attachments of content
    my %Opts = (
        ExcludePlainText => 1,
    );

    # check if rich text is enabled, if not only stip ascii attachments
    if ( $Self->{RichText} ) {
        $Opts{ExcludeHTMLBody} = 1;
    }

    my ($TicketID) = $ParamObject->GetParam( Param => 'TicketID' );;

    return {} if !$TicketID;

    my @ArticleIndex    = $ArticleObject->ArticleList( TicketID => $TicketID );
    my $CanDelete       = $ConfigObject->Get( 'Attachmentlist::CanDelete' );
    my $CanRename       = $ConfigObject->Get( 'Attachmentlist::CanRename' );
    my $ConfirmDeletion = $ConfigObject->Get( 'Attachmentlist::ConfirmDeletionDialog' );

    my $Access;

    if ( $CanDelete || $CanRename ) {
        $Access = $TicketObject->TicketPermission(
            Type     => 'rw',
            TicketID => $TicketID,
            UserID   => $Self->{UserID},
            LogNo    => 1,
        );
    }

    my $HasAttachments;

    my @ExcludeFilenames = @{ $ConfigObject->Get( 'Attachmentlist::ExcludeFilenames' ) || [] };

    for my $Article ( @ArticleIndex ) {

        my $ArticleID = $Article->{ArticleID};

        my $BackendObject = $ArticleObject->BackendForArticle(
            TicketID  => $TicketID,
            ArticleID => $ArticleID,
        );


        next ARTICLEID if !$BackendObject->can('ArticleAttachmentIndex');

        my %Article = $BackendObject->ArticleGet(
            TicketID  => $TicketID,
            ArticleID => $ArticleID,
        );

        # get attachment index (without attachments)
        my %AtmIndex = $BackendObject->ArticleAttachmentIndex(
            ArticleID => $ArticleID,
            TicketID  => $TicketID,
            Article   => \%Article,
            %Opts,
            UserID    => $Self->{UserID},
        );

        my $StorageModule = $Kernel::OM->Get( $BackendObject->{ArticleStorageModule} );

        my $AttachmentNr = 0;

        ATTACHMENTID:
        for my $AttachmentID ( sort keys %AtmIndex ) {

            my $Filename = $AtmIndex{$AttachmentID}->{Filename};

            next ATTACHMENTID if first { $Self->_Check( $Filename, $_ ) } @ExcludeFilenames;

            my $Size = $UtilsObject->FormatSize( $AtmIndex{$AttachmentID}->{FilesizeRaw} );

            $AttachmentNr++;

            my %AttachmentInfo = (
                AttachmentID    => $AttachmentID,
                AttachmentTitle => $Filename,
                AttachmentDate  => $Article{CreateTime},
                ArticleID       => $Article{ArticleID},
                TicketID        => $Article{TicketID},
                Filesize        => $Size,
                ContentType     => $AtmIndex{$AttachmentID}->{ContentType},
                AttachmentNr    => $AttachmentNr,
            );

            $LayoutObject->Block(
                Name => 'Attachment',
                Data => \%AttachmentInfo,
            );

            $HasAttachments++;

            if ( ( $CanDelete && $Access ) || ( $CanRename && $Access ) ) {
                $LayoutObject->Block(
                    Name => 'Links',
                );
            }

            if ( $CanDelete && $Access ) {
                $LayoutObject->Block(
                    Name => 'DeleteLink',
                    Data => \%AttachmentInfo,
                );

                if ( $ConfirmDeletion ) {
                    $LayoutObject->Block(
                        Name => 'ConfirmDeletion',
                        Data => \%AttachmentInfo,
                    );
                }
            }

            if ( $CanRename && $Access ) {
                $LayoutObject->Block(
                    Name => 'RenameLink',
                    Data => \%AttachmentInfo,
                );
            }
        }
    }

    return {} if !$HasAttachments;

    my $Snippet = $LayoutObject->Output(
        TemplateFile => 'ShowTicketAttachmentlistSnippet',
        Data         => {
            TicketID => $TicketID,
        },
    ); 

    my $Config = $Param{Config};

    return {
        Output => $Snippet,
        Rank   => $Config->{Rank},
    };
}

sub _Check {
    my ($Self, $Filename, $Check) = @_;

    my $Result;
    if ( $Self->{CompareMethod} eq 'string_match' ) {
        $Result = $Filename eq $Check;
    }
    else {
        $Result = $Filename =~ m{$Check};
    }

    return $Result;
}

1;
