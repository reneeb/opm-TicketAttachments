# --
# Kernel/Output/HTML/OutputFilter/Attachmentlist.pm
# Copyright (C) 2011 - 2015 Perl-Services.de, http://www.perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::OutputFilter::Attachmentlist;

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

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $MainObject   = $Kernel::OM->Get('Kernel::System::Main');

    # get template name
    my $Templatename = $Param{TemplateFile} || '';
    return 1 if !$Templatename;

    return 1 if $Templatename ne 'AgentTicketZoom';

    # define if rich text should be used
    $Self->{RichText}
        = $ConfigObject->Get('Ticket::Frontend::ZoomRichTextForce')
        || $LayoutObject->{BrowserRichText}
        || 0;

    # strip html and ascii attachments of content
    $Self->{StripPlainBodyAsAttachment} = 1;

    # check if rich text is enabled, if not only stip ascii attachments
    if ( !$Self->{RichText} ) {
        $Self->{StripPlainBodyAsAttachment} = 2;
    }

    my ($TicketID) = $ParamObject->GetParam( Param => 'TicketID' );;

    return 1 if !$TicketID;

    my @ArticleIndex    = $TicketObject->ArticleIndex( TicketID => $TicketID );
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

    for my $ArticleID ( @ArticleIndex ) {

        my %Article = $TicketObject->ArticleGet( ArticleID => $ArticleID );

        # get attachment index (without attachments)
        my %AtmIndex = $TicketObject->ArticleAttachmentIndex(
            ArticleID                  => $ArticleID,
            StripPlainBodyAsAttachment => $Self->{StripPlainBodyAsAttachment},
            Article                    => \%Article,
            UserID                     => $Self->{UserID},
        );

        ATTACHMENTID:
        for my $AttachmentID ( sort keys %AtmIndex ) {

            my $Filename = $AtmIndex{$AttachmentID}->{Filename};

            next ATTACHMENTID if first { $Self->_Check( $Filename, $_ ) } @ExcludeFilenames;

            my %AttachmentInfo = (
                AttachmentID    => $AttachmentID, 
                AttachmentTitle => $Filename,
                AttachmentDate  => $Article{Created},
                ArticleID       => $Article{ArticleID},
                TicketID        => $Article{TicketID},
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

    if ( $HasAttachments ) {
    
        if ( $Templatename eq 'AgentTicketZoom' ) {
            my $Snippet = $LayoutObject->Output(
                TemplateFile => 'ShowTicketAttachmentlistSnippet',
                Data         => {
                    TicketID => $TicketID,
                },
            ); 
    
            #scan html output and generate new html input
            my $Position = $ConfigObject->Get( 'TicketAttachments::Position' ) || 'top';

            if ( $Position eq 'bottom' ) {
                ${ $Param{Data} } =~ s{(</div> \s+ <div \s+ class="ContentColumn)}{ $Snippet $1 }xms;
            }
            else {
                ${ $Param{Data} } =~ s{(<div \s+ class="SidebarColumn">)}{$1 $Snippet}xsm;
            }
        }
    }

    return ${ $Param{Data} };
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
