# --
# Kernel/Modules/AgentAttachmentDelete.pm - to get a closer view
# Copyright (C) 2011 - 2014 Perl-Services.de, http://perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentAttachmentDelete;

use strict;
use warnings;

our $VERSION = 0.02;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    # set debug
    $Self->{Debug} = 0;

    # get params
    $Self->{ArticleID} = $ParamObject->GetParam( Param => 'ArticleID' );
    $Self->{FileID}    = $ParamObject->GetParam( Param => 'FileID' );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # check needed stuff
    if ( !$Self->{ArticleID} ) {
        return $LayoutObject->ErrorScreen(
            Message => 'No ArticleID is given!',
            Comment => 'Please contact the admin.',
        );
    }

    # check needed stuff
    if ( !$ConfigObject->Get( 'Attachmentlist::CanDelete' ) ) {
        return $LayoutObject->ErrorScreen(
            Message => 'Attachment deletion is not allowed!',
            Comment => 'Please contact the admin.',
        );
    }

    my %Article = $TicketObject->ArticleGet(
        ArticleID => $Self->{ArticleID},
        UserID    => $Self->{UserID},
    );

    my $TicketID = $Article{TicketID};

    # check permissions
    my $Access = $TicketObject->TicketPermission(
        Type     => 'rw',
        TicketID => $TicketID,
        UserID   => $Self->{UserID}
    );

    # error screen, don't show ticket
    if ( !$Access ) {
        return $LayoutObject->NoPermission( WithHeader => 'yes' );
    }

    $TicketObject->ArticleDeleteSingleAttachment(
        ArticleID => $Self->{ArticleID},
        UserID    => $Self->{UserID},
        FileID    => $Self->{FileID},
        TicketID  => $TicketID,
    );

    # return output
    return $LayoutObject->Redirect(
        OP => "Action=AgentTicketZoom;TicketID=$TicketID",
    );
}

1;
