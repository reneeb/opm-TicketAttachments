# --
# Kernel/Language/en_TicketAttachments.pm - English translations for TicketAttachments
# Copyright (C) 2012 - 2023 Perl-Services.de, https://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::en_TicketAttachments;

use strict;
use warnings;

use utf8;

sub Data {
    my $Self = shift;

    my $Lang = $Self->{Translation} || {};

    # Kernel/Config/Files/TicketAttachments.xml
    $Lang->{'Modul to show ticket attachments.'} = '';
    $Lang->{'Enable/Disable deletion feature.'} = '';
    $Lang->{'No'} = '';
    $Lang->{'Yes'} = '';
    $Lang->{'Show a dialog to confirm the deletion of the attachment.'} = '';
    $Lang->{'Enable/Disable rename feature.'} = '';
    $Lang->{'Frontend module registration for attachment deletion module.'} = '';
    $Lang->{'Delete ticket attachments.'} = '';
    $Lang->{'Delete Ticket Attachments'} = '';
    $Lang->{'Frontend module registration for attachment rename module.'} = '';
    $Lang->{'Rename ticket attachments.'} = '';
    $Lang->{'Rename Ticket Attachments'} = '';
    $Lang->{'Files with those names are not listed.'} = '';
    $Lang->{'Define which method is used to exclude files.'} = '';
    $Lang->{'exact string match'} = '';
    $Lang->{'pattern match'} = '';
    $Lang->{'Enable/Disable debugging output.'} = '';
    $Lang->{'Define where in the Sidebar the ticket attachment widget is located.'} = '';
    $Lang->{'Top'} = '';
    $Lang->{'Bottom'} = '';

    # Kernel/Output/HTML/Templates/Standard/AgentAttachmentRename.tt:
    $Lang->{'Rename Attachment'} = '';
    $Lang->{'Cancel & close window'} = '';
    $Lang->{'Options'} = '';
    $Lang->{'Rename to'} = '';
    $Lang->{'Invalid filename!'} = '';
    $Lang->{'Submit'} = '';

    # Kernel/Output/HTML/Templates/Standard/ShowTicketAttachmentlistSnippet.tt
    $Lang->{'Show or hide the content'} = '';
    $Lang->{'Ticket Attachments'} = '';
    $Lang->{'delete'} = '';
    $Lang->{'rename'} = '';
    $Lang->{'Delete Attachment?'} = '';
    $Lang->{'Do you want to delete the attachment? This operation can\'t be undone!'} = '';
    $Lang->{'Delete'} = '';
    $Lang->{'Cancel'} = '';

    # Kernel/Modules/AgentAttachmentDelete.pm
    $Lang->{'No ArticleID is given!'} = '';
    $Lang->{'Please contact the administrator.'} = '';
    $Lang->{'Attachment deletion is not allowed!'} = '';

    # Kernel/Modules/AgentAttachmentRename.pm
    $Lang->{'Attachment rename is not allowed!'} = '';
    $Lang->{'Article not found'} = '';
    $Lang->{'Sorry, you need "rw permissions" to do this action!'} = '';
    $Lang->{'Please change the owner first.'} = '';

    # HistoryComments (TicketAttachments.sopm) 
    $Lang->{'Rename an attachment'} = '';
    $Lang->{'Delete an attachment'} = '';

    return 1;
}

1;
