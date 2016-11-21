# --
# Kernel/Language/hu_TicketAttachments.pm - Hungarian translations for TicketAttachments
# Copyright (C) 2012-2016 Perl-Services.de, http://perl-services.de
# Copyright (C) 2016 Balázs Úr, http://www.otrs-megoldasok.hu
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::hu_TicketAttachments;

use strict;
use warnings;

use utf8;

sub Data {
    my $Self = shift;

    my $Lang = $Self->{Translation} || {};

    # Kernel/Config/Files/TicketAttachments.xml
    $Lang->{'Modul to show ticket attachments.'} = 'Egy modul a jegymellékletek megjelenítéséhez.';
    $Lang->{'Enable/Disable deletion feature.'} = 'A törlési funkció engedélyezése vagy letiltása.';
    $Lang->{'No'} = 'Nem';
    $Lang->{'Yes'} = 'Igen';
    $Lang->{'Show a dialog to confirm the deletion of the attachment.'} =
        'Egy párbeszédablak megjelenítése a melléklet törlésének megerősítéséhez.';
    $Lang->{'Enable/Disable rename feature.'} = 'Az átnevezési funkció engedélyezése vagy letiltása.';
    $Lang->{'Frontend module registration for attachment deletion module.'} =
        'Előtétprogram-modul regisztráció a melléklet törlési modulhoz.';
    $Lang->{'Delete ticket attachments.'} = 'Jegymellékletek törlése.';
    $Lang->{'Delete Ticket Attachments'} = 'Jegymellékletek törlése';
    $Lang->{'Frontend module registration for attachment rename module.'} =
        'Előtétprogram-modul regisztráció a melléklet átnevezési modulhoz.';
    $Lang->{'Rename ticket attachments.'} = 'Jegymellékletek átnevezése.';
    $Lang->{'Rename Ticket Attachments'} = 'Jegymellékletek átnevezése';
    $Lang->{'Files with those names are not listed.'} = 'Az ilyen nevű fájlok nincsenek felsorolva.';
    $Lang->{'Define which method is used to exclude files.'} =
        'Annak meghatározása, hogy melyik módszer használatával zárja ki a fájlokat.';
    $Lang->{'exact string match'} = 'pontos szövegegyezés';
    $Lang->{'pattern match'} = 'mintaillesztés';
    $Lang->{'Enable/Disable debugging output.'} = 'Hibakeresési kimenet engedélyezése vagy letiltása.';
    $Lang->{'Define where in the Sidebar the ticket attachment widget is located.'} =
        'Annak meghatározása, hogy az oldalsávon hol helyezkedjen el a jegymelléklet felületi elem.';
    $Lang->{'Top'} = 'Fent';
    $Lang->{'Bottom'} = 'Lent';

    # Kernel/Output/HTML/Templates/Standard/AgentAttachmentRename.tt:
    $Lang->{'Rename Attachment'} = 'Melléklet átnevezése';
    $Lang->{'Cancel & close window'} = 'Mégse és ablak bezárása';
    $Lang->{'Options'} = 'Beállítások';
    $Lang->{'Rename to'} = 'Átnevezés erre';
    $Lang->{'Invalid filename!'} = 'Érvénytelen fájlnév!';
    $Lang->{'Submit'} = 'Elküldés';

    # Kernel/Output/HTML/Templates/Standard/ShowTicketAttachmentlistSnippet.tt
    $Lang->{'Show or hide the content'} = 'A tartalom megjelenítése vagy elrejtése';
    $Lang->{'Ticket Attachments'} = 'Jegymellékletek';
    $Lang->{'delete'} = 'törlés';
    $Lang->{'rename'} = 'átnevezés';
    $Lang->{'Delete Attachment?'} = 'Törli a mellékletet?';
    $Lang->{'Do you want to delete the attachment? This operation can\'t be undone!'} =
        'Törölni szeretné a mellékletet? Ezt a műveletet nem lehet visszavonni!';
    $Lang->{'Delete'} = 'Törlés';
    $Lang->{'Cancel'} = 'Mégse';

    # Kernel/Modules/AgentAttachmentDelete.pm
    $Lang->{'No ArticleID is given!'} = 'Nincs bejegyzés-azonosító megadva!';
    $Lang->{'Please contact the administrator.'} = 'Vegye fel a kapcsolatot a rendszergazdával.';
    $Lang->{'Attachment deletion is not allowed!'} = 'A melléklet törlése nem engedélyezett!';

    # Kernel/Modules/AgentAttachmentRename.pm
    $Lang->{'Attachment rename is not allowed!'} = 'A melléklet átnevezése nem engedélyezett!';
    $Lang->{'Article not found'} = 'A bejegyzés nem található';
    $Lang->{'Sorry, you need "rw permissions" to do this action!'} =
        'Sajnáljuk, „írási-olvasási jogosultságra” van szüksége a művelet elvégzéséhez!';
    $Lang->{'Please change the owner first.'} = 'Először változtassa meg a tulajdonost.';

    # HistoryComments (TicketAttachments.sopm) 
    $Lang->{'Rename an attachment'} = 'Egy melléklet átnevezése';
    $Lang->{'Delete an attachment'} = 'Egy melléklet törlése';

    return 1;
}

1;
