package Quantum::Simplified::Role::Operation;

our $VERSION = '1.00';

use Modern::Perl "2017";
use Moo::Role;

use feature qw(signatures);
no warnings qw(experimental::signatures);

requires qw(
	run
	supported_types
);

has "sign" => (
	is => "ro",
);

1;
