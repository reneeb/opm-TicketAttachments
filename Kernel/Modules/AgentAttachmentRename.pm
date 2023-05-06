# --
# Copyright (C) 2012 - 2023 Perl-Services.de, https://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentAttachmentRename;

use strict;
use warnings;

use Kernel::Language qw(Translatable);

use List::Util qw(first);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # set debug
    $Self->{Debug} = $ConfigObject->Get('Attachmentlist::Debug') || 0;

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ParamObject   = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject  = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject  = $Kernel::OM->Get('Kernel::Config');
    my $TicketObject  = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ArticleObject = $Kernel::OM->Get('Kernel::System::Ticket::Article');
    my $MainObject    = $Kernel::OM->Get('Kernel::System::Main');
    my $LogObject     = $Kernel::OM->Get('Kernel::System::Log');

    my %GetParam;
    for my $ParamName ( qw/ArticleID FileID TicketID NewFilename/ ) {
        $GetParam{$ParamName} = $ParamObject->GetParam( Param => $ParamName ) || '';
    }

    # check needed stuff
    if ( !$GetParam{ArticleID} || !$GetParam{TicketID} ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('No ArticleID or TicketID is given!'),
            Comment => Translatable('Please contact the admin.'),
        );
    }

    # check needed stuff
    if ( !$ConfigObject->Get( 'Attachmentlist::CanRename' ) ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('Attachment rename is not allowed!'),
            Comment => Translatable('Please contact the admin.'),
        );
    }

    # check if the user belongs to a group
    # that is allowed to rename attachments
    my $Access = $TicketObject->TicketPermission(
        Type     => 'rw',
        TicketID => $GetParam{TicketID},
        UserID   => $Self->{UserID}
    );

    if ( $Self->{Debug} ) {
        $LogObject->Log(
            Priority => 'debug',
            Message  => "$GetParam{TicketID} // $Access",
        );
    }

    my $BackendObject = $ArticleObject->BackendForArticle(
        ArticleID => $GetParam{ArticleID},
        TicketID  => $GetParam{TicketID},
    );

    my %Article = $BackendObject->ArticleGet(
        ArticleID => $GetParam{ArticleID},
        TicketID  => $GetParam{TicketID},
    );

    if ( !%Article ) {
        return $LayoutObject->ErrorScreen(
            Message => 'Article not found',
            Comment => 'Please contact the admin.',
        );
    }

    # error screen, don't show ticket
    if ( !$Access ) {
        my $Output = $LayoutObject->Header(
            Type  => 'Small',
            Value => $Article{TicketNumber},
        );

        $Output .= $LayoutObject->Warning(
            Message => 'Sorry, you need "rw permissions" to do this action!',
            Comment => 'Please change the owner first.',
        );

        $Output .= $LayoutObject->Footer(
            Type => 'Small',
        );

        return $Output;
    }

    my $StorageModule  = $Kernel::OM->Get( $BackendObject->{ArticleStorageModule} );

    if ( $Self->{Subaction} eq 'Rename' ) {
        my $CheckFilename = $MainObject->FilenameCleanUp(
            Filename => $GetParam{NewFilename},
            Type     => 'Local',
        );

        my $Success;
        if ( $CheckFilename eq $GetParam{NewFilename} ) {
            $Success = $StorageModule->AttachmentRename(
                ArticleID => $GetParam{ArticleID},
                TicketID  => $GetParam{TicketID},
                UserID    => $Self->{UserID},
                FileID    => $GetParam{FileID},
                Filename  => $GetParam{NewFilename},
            );
        }

        if ( $Self->{Debug} ) {
            $LogObject->Log(
                Priority => 'notice',
                Message  => "Success: $Success",
            );
        }

        if ( !$Success ) {
            $GetParam{NewFilenameInvalid} = 'ServerError';
        }
        else {

            # return output
            return $LayoutObject->PopupClose(
                URL => "Action=AgentTicketZoom;TicketID=$GetParam{TicketID};ArticleID=$GetParam{ArticleID}",
            );
        }
    }

    my $Output = $LayoutObject->Header(
        Type  => 'Small',
        Value => $Article{TicketNumber},
    );

    my ($ID,$Filename) = $StorageModule->AttachmentInfoGet(
        ArticleID => $GetParam{ArticleID},
        FileID    => $GetParam{FileID},
    );

    $Output .= $LayoutObject->Output(
         TemplateFile => 'AgentAttachmentRename',
         Data         => {
             %GetParam,
             AttachmentID => $ID,
             Filename     => $Filename,
         }, 
    );

    $Output .= $LayoutObject->Footer(
        Type => 'Small',
    );

    return $Output;
}

1;
