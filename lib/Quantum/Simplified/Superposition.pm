package Quantum::Simplified::Superposition;

our $VERSION = '1.00';

use Modern::Perl "2017";
use Moo;

use feature qw(signatures);
no warnings qw(experimental::signatures);

use Quantum::Simplified::State;
use Quantum::Simplified::Computation;
use Types::Standard qw(ArrayRef InstanceOf);
use List::Util qw(sum);
use Carp qw(croak);

sub rng { rand }

sub create_computation(@args)
{
	my $type = pop @args;
	pop @args; # discard the order
	my $computation = Quantum::Simplified::Computation->new(
		operation => $type,
		value => [@args],
	);

	return __PACKAGE__->new(states => [$computation]);
}

use namespace::clean;

with "Quantum::Simplified::Roles::Collapsible";

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
				ArrayRef->where(q{@$_ == 2}), q{ Quantum::Simplified::State->new(weight => shift @$_, value => shift @$_) },
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
		return $state->get_value if $prop < 0;
	}
}

sub reset($self)
{
	foreach my $state ($self->states->@*) {
		$state->reset;
	}
	$self->_reset;
}

use overload
	q{nomethod} => \&create_computation,

	q{""} => "_collapse",
;

1;
