package Quantum::Simplified::ComputedState;

our $VERSION = '1.00';

use Modern::Perl "2017";
use Moo;

use feature qw(signatures);
no warnings qw(experimental::signatures);

use Quantum::Simplified::Role::Operation;
use Types::Standard qw(ConsumerOf ArrayRef);

use namespace::clean;

extends "Quantum::Simplified::State";

has "source" => (
	is => "ro",
	isa => ArrayRef,
	required => 1,
);

has "operation" => (
	is => "ro",
	isa => ConsumerOf["Quantum::Simplified::Role::Operation"],
	required => 1,
);

sub clone($self)
{
	return $self->new(
		$self->%{qw(value weight source operation)}
	);
}

1;

