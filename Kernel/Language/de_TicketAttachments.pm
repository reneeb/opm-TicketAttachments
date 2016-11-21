# --
# Kernel/Language/de_TicketAttachments.pm - German translations for TicketAttachments
# Copyright (C) 2012 - 2014 Perl-Services.de, http://perl-services.de
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

    $Lang->{'delete'}  = 'Löschen';
    $Lang->{'rename'}  = 'Umbenennen';
    $Lang->{'Rename Attachment'} = 'Benenne Anhang um';
    $Lang->{'Rename to'}         = 'Umbenennen in';

    $Lang->{'Ticket Attachments'} = 'Ticket-Anhänge';

    $Lang->{'Invalid filename!'} = 'Ungültiger Dateiname';

    $Lang->{'History::AttachmentRename'} = 'Umbenennen des Anhangs %s nach %s.';
    $Lang->{'History::AttachmentDelete'} = 'Anhang %s gelöscht.';

    $Lang->{'Files with those names are not listed.'} = 'Diese Dateien werden nicht aufgelistet.';
    $Lang->{'Enable/Disable debugging output'}        = 'Ein-/Ausschalten der Debug-Ausgaben.';
    $Lang->{'Enable/Disable rename feature.'}         = 'Ein-/Ausschalten der Umbenennen-Funktion.';
    $Lang->{'Enable/Disable deletion feature.'}       = 'Ein-/Ausschalten der Löschen-Funktion.';

    return 1;
}

1;
