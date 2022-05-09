# --
# Copyright (C) 2017 - 2022 Perl-Services.de, https://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::TicketAttachments::Utils;

use strict;
use warnings;

our @ObjectDependencies = qw(
    Kernel::Config
    Kernel::System::Log
    Kernel::System::Encode
    Kernel::System::Main
    Kernel::System::Time
    Kernel::System::DB
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub FormatSize {
    my ($Self, $Size) = @_;

    my $Formatted = "$Size B";
    my $KB        = 1024;

    if ( $Size > $KB * 1024 ) {
        $Formatted = sprintf "%.2f MB", $Size / ( $KB * 1024 );
    }
    elsif ( $Size > $KB ) {
        $Formatted = sprintf "%.2f KB", $Size / $KB;
    }

    return $Formatted;
}

1;
