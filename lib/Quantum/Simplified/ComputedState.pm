package Quantum::Simplified::ComputedState;

our $VERSION = '1.00';

use v5.24; use warnings;
use Moo;

use feature qw(signatures);
no warnings qw(experimental::signatures);

use Quantum::Simplified::Role::Operation;
use Types::Standard qw(ConsumerOf ArrayRef);
use Carp qw(croak);

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

# TODO: allow merging with regular states
sub merge($self, $with)
{
	croak "cannot merge a state: values mismatch"
		if $self->value ne $with->value;
	croak "cannot merge a state: operation mismatch"
		if $self->operation->sign ne $with->operation->sign;

	return $self->new(
		weight => $self->weight + $with->weight,
		operation => $self->operation,
		value => $self->value,
		source => [$self->source->@*, $with->source->@*],
	);
}

1;

