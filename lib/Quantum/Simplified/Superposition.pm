package Quantum::Simplified::Superposition;

our $VERSION = '1.00';

use Modern::Perl "2017";
use Moo;

use feature qw(signatures);
no warnings qw(experimental::signatures);

use Quantum::Simplified::State;
use Types::Standard qw(ArrayRef InstanceOf);
use List::Util qw(sum);
use Carp qw(croak);

sub rng { rand }

use namespace::clean;

has "collapse" => (
	is => "ro",
	lazy => 1,
	builder => "_collapse",
	clearer => "_reset",
	predicate => "is_collapsed",
);

has "states" => (
	is => "ro",
	isa => ArrayRef[
		(InstanceOf["Quantum::Simplified::State"])
			->plus_coercions(
				ArrayRef, q{ Quantum::Simplified::State->new(weight => shift @$_, value => shift @$_) },
				~InstanceOf["Quantum::Simplified::State"], q{ Quantum::Simplified::State->new(value => $_) },
			)
	],
	trigger => sub ($self, $old) { $self->_clear_weight_sum },
	coerce => 1,
	required => 1,
);

has "_weight_sum" => (
	is => "ro",
	lazy => 1,
	default => sub ($self) { sum map { $_->weight } $self->states->@* },
	clearer => 1,
);

sub _collapse($self)
{
	my @positions = $self->states->@*;
	my $sum = $self->_weight_sum;
	my $prop = rng;

	foreach my $state (@positions) {
		$prop -= $state->weight / $sum;
		return $state->value if $prop < 0;
	}
}

sub reset($self)
{
	$self->_reset;
}

1;
