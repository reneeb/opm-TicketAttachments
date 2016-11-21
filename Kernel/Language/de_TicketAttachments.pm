# --
# Kernel/Language/de_TicketAttachments.pm - German translations for TicketAttachments
# Copyright (C) 2012-2016 Perl-Services.de, http://perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_TicketAttachments;

use strict;
use warnings;

use utf8;

sub Data {
    my $Self = shift;

    my $Lang = $Self->{Translation} || {};

    # Kernel/Config/Files/TicketAttachments.xml
    $Lang->{'Modul to show ticket attachments.'} = '';
    $Lang->{'Enable/Disable deletion feature.'} = 'Ein-/Ausschalten der Löschen-Funktion.';
    $Lang->{'No'} = 'Nein';
    $Lang->{'Yes'} = 'Ja';
    $Lang->{'Show a dialog to confirm the deletion of the attachment.'} = '';
    $Lang->{'Enable/Disable rename feature.'} = 'Ein-/Ausschalten der Umbenennen-Funktion.';
    $Lang->{'Frontend module registration for attachment deletion module.'} =
        'Frontendmodul-Registration für das Anhang-Löschen-Modul.';
    $Lang->{'Delete ticket attachments.'} = '';
    $Lang->{'Delete Ticket Attachments'} = '';
    $Lang->{'Frontend module registration for attachment rename module.'} =
        'Frontendmodul-Registration für das Anhang-Umbenennen-Modul.';
    $Lang->{'Rename ticket attachments.'} = '';
    $Lang->{'Rename Ticket Attachments'} = '';
    $Lang->{'Files with those names are not listed.'} = 'Diese Dateien werden nicht aufgelistet.';
    $Lang->{'Define which method is used to exclude files.'} = '';
    $Lang->{'exact string match'} = '';
    $Lang->{'pattern match'} = '';
    $Lang->{'Enable/Disable debugging output.'} = 'Ein-/Ausschalten der Debug-Ausgaben.';
    $Lang->{'Define where in the Sidebar the ticket attachment widget is located.'} = '';
    $Lang->{'Top'} = '';
    $Lang->{'Bottom'} = '';

    # Kernel/Output/HTML/Templates/Standard/AgentAttachmentRename.tt:
    $Lang->{'Rename Attachment'} = 'Benenne Anhang um';
    $Lang->{'Cancel & close window'} = '';
    $Lang->{'Options'} = '';
    $Lang->{'Rename to'} = 'Umbenennen in';
    $Lang->{'Invalid filename!'} = 'Ungültiger Dateiname';
    $Lang->{'Submit'} = '';

    # Kernel/Output/HTML/Templates/Standard/ShowTicketAttachmentlistSnippet.tt
    $Lang->{'Show or hide the content'} = '';
    $Lang->{'Ticket Attachments'} = 'Ticket-Anhänge';
    $Lang->{'delete'} = 'Löschen';
    $Lang->{'rename'} = 'Umbenennen';
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
