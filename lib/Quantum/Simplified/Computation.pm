package Quantum::Simplified::Computation;

our $VERSION = '1.00';

use Modern::Perl "2017";
use Moo;

use feature qw(signatures);
no warnings qw(experimental::signatures);

use Types::Common::Numeric qw(PositiveNum);
use Types::Standard qw(Defined);
use Carp qw(croak);
use Scalar::Util qw(blessed);
use List::Util qw(first reduce);
use List::MoreUtils qw(natatime);

use namespace::clean;

extends "Quantum::Simplified::State";


sub get_collapsed
{
	return map {
		(blessed $_ && $_->isa("Quantum::Simplified")) ? $_->collapse :
		(ref $_ eq "CODE")                             ? $_->()       :
		                                                 $_           ;
	} @_;
}

1;

