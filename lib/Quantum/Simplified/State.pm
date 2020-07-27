package Quantum::Simplified::State;

our $VERSION = '1.00';

use v5.24; use warnings;
use Moo;

use feature qw(signatures);
no warnings qw(experimental::signatures);

use Quantum::Simplified::Util qw(is_collapsible);
use Types::Common::Numeric qw(PositiveNum);
use Types::Standard qw(Defined);
use Carp qw(croak);

use namespace::clean;

has "weight" => (
	is => "ro",
	isa => PositiveNum,
	default => sub { 1 },
);

# TODO: should this assert for definedness?
has "value" => (
	is => "ro",
	isa => Defined,
	required => 1,
);

sub reset($self)
{
	if (is_collapsible $self->value) {
		$self->value->reset;
	}
}

sub clone($self)
{
	return $self->new(
		$self->%{qw(value weight)}
	);
}

sub merge($self, $with)
{
	croak "cannot merge a state: values mismatch"
		if $self->value ne $with->value;

	return $self->new(
		weight => $self->weight + $with->weight,
		value => $self->value,
	);
}

sub clone_with($self, %transformers)
{
	my $cloned = $self->clone;
	for my $to_transform (keys %transformers) {
		if ($self->can($to_transform) && exists $cloned->{$to_transform}) {
			$cloned->{$to_transform} = $transformers{$to_transform}->($cloned->{$to_transform});
		}
	}

	return $cloned;
}

1;

