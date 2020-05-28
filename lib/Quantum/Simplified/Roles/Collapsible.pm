package Quantum::Simplified::Roles::Collapsible;

our $VERSION = '1.00';

use Modern::Perl "2017";
use Moo::Role;

requires qw(
	_collapse
	reset
);

1;
