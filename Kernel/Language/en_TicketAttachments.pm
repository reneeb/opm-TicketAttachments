# --
# Kernel/Language/en_TicketAttachments.pm - English translations for TicketAttachments
# Copyright (C) 2012 Perl-Services.de
# --
# $Id: en_TicketAttachments.pm,v 1.4 2012-01-18 09:41:29 fober Exp $
#
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::en_TicketAttachments;

use strict;
use warnings;

sub Data {
    my $Self = shift;

    my $Lang = $Self->{Translation} || {};

    $Lang->{'History::AttachmentRename'} = 'Renamed attachment %s to %s.';
    $Lang->{'History::AttachmentDelete'} = 'Attachment %s deleted.';

    return 1;
}

1;
