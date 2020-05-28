package Quantum::Simplified::Roles::Collapsible;

our $VERSION = '1.00';

use Modern::Perl "2017";
use Moo::Role;

use feature qw(signatures);
no warnings qw(experimental::signatures);

use Quantum::Simplified::Computation;

sub create_computation(@args)
{
	my $type = pop @args;
	pop @args; # discard the order
	return Quantum::Simplified::Computation->new(
		operation => $type,
		values => [@args],
	);
}

use namespace::clean;

requires qw(
	collapse
	is_collapsed
	reset
);

use overload
	q{nomethod} => \&create_computation,

	q{""} => "collapse",
;
1;
