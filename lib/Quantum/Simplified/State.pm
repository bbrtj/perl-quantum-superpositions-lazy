package Quantum::Simplified::State;

our $VERSION = '1.00';

use Modern::Perl "2017";
use Moo;

use feature qw(signatures);
no warnings qw(experimental::signatures);

use Types::Common::Numeric qw(PositiveNum);
use Types::Standard qw(Defined);

use namespace::clean;

has "weight" => (
	is => "ro",
	isa => PositiveNum,
	default => sub { 1 },
);

has "value" => (
	is => "ro",
	isa => Defined,
	required => 1,
);

sub get_value($self)
{
	return $self->value;
}

1;

