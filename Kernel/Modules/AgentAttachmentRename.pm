# --
# Kernel/Modules/AgentAttachmentRename.pm - to get a closer view
# Copyright (C) 2012 - 2014 Perl-Services.de, http://perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentAttachmentRename;

use strict;
use warnings;

use List::Util qw(first);

our $VERSION = 0.02;

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

    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $MainObject   = $Kernel::OM->Get('Kernel::System::Main');
    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');

    my %GetParam;
    for my $ParamName ( qw/ArticleID FileID TicketID NewFilename/ ) {
        $GetParam{$ParamName} = $ParamObject->GetParam( Param => $ParamName ) || '';
    }

    # check needed stuff
    if ( !$GetParam{ArticleID} ) {
        return $LayoutObject->ErrorScreen(
            Message => 'No ArticleID is given!',
            Comment => 'Please contact the admin.',
        );
    }

    # check needed stuff
    if ( !$ConfigObject->Get( 'Attachmentlist::CanRename' ) ) {
        return $LayoutObject->ErrorScreen(
            Message => 'Attachment rename is not allowed!',
            Comment => 'Please contact the admin.',
        );
    }

    my %Article = $TicketObject->ArticleGet(
        ArticleID => $GetParam{ArticleID},
        UserID    => $Self->{UserID},
    );

    if ( !%Article ) {
        return $LayoutObject->ErrorScreen(
            Message => 'Article not found',
            Comment => 'Please contact the admin.',
        );
    }

    my $TicketID = $Article{TicketID};

    # check if the user belongs to a group
    # that is allowed to rename attachments
    my $Access = $TicketObject->TicketPermission(
        Type     => 'rw',
        TicketID => $TicketID,
        UserID   => $Self->{UserID}
    );

    if ( $Self->{Debug} ) {
        $LogObject->Log(
            Priority => 'notice',
            Message  => "$TicketID // $Access",
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

    if ( $Self->{Subaction} eq 'Rename' ) {
        my $CheckFilename = $MainObject->FilenameCleanUp(
            Filename => $GetParam{NewFilename},
            Type     => 'Local',
        );

        my $Success;
        if ( $CheckFilename eq $GetParam{NewFilename} ) {
            $Success = $TicketObject->AttachmentRename(
                ArticleID => $GetParam{ArticleID},
                UserID    => $Self->{UserID},
                FileID    => $GetParam{FileID},
                TicketID  => $TicketID,
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

    my ($ID,$Filename) = $Self->_AttachmentInfoGet(
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

sub _AttachmentInfoGet {
    my ($Self, %Param) = @_;

    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    my %GetParam;
    # try database
    return if !$DBObject->Prepare(
        SQL => 'SELECT id, filename FROM article_attachment WHERE article_id = ? ORDER BY filename, id',
        Bind   => [ \$Param{ArticleID} ],
        Limit  => $Param{FileID},
    );

    my $AttachmentID;
    my $Filename;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $AttachmentID = $Row[0];
        $Filename     = $Row[1];
    }

    return if !$AttachmentID;
    return if !$Filename;

    return ($AttachmentID, $Filename);
}


1;
