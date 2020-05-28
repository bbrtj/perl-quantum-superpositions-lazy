package Quantum::Simplified::Util;

our $VERSION = '1.00';

use Modern::Perl "2017";
use feature qw(signatures);
no warnings qw(experimental::signatures);

use Exporter qw(import);
use Scalar::Util qw(blessed);

our @EXPORT_OK = qw(
	is_collapsible
	get_rand
);

sub is_collapsible($item)
{
	return blessed $item && $item->DOES("Quantum::Simplified::Roles::Collapsible");
}

sub get_rand { rand }

1;
