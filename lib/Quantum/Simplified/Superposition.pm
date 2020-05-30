package Quantum::Simplified::Superposition;

our $VERSION = '1.00';

use Modern::Perl "2017";
use Moo;

use feature qw(signatures);
no warnings qw(experimental::signatures);

use Quantum::Simplified::State;
use Quantum::Simplified::Computation;
use Quantum::Simplified::Util qw(get_rand is_collapsible);
use Types::Standard qw(ArrayRef InstanceOf);
use List::Util qw(sum);

use namespace::clean;

with "Quantum::Simplified::Role::Collapsible";

has "_collapsed_state" => (
	is => "ro",
	lazy => 1,
	builder => "_observe",
	clearer => "_reset",
	predicate => "_is_collapsed",
	init_arg => undef,
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
	coerce => 1,
	required => 1,
	trigger => sub ($self, $old) {
		$self->_clear_weight_sum;
		$self->_clear_eigenstates;
		$self->_reset;
	},
);

has "_weight_sum" => (
	is => "ro",
	lazy => 1,
	default => sub ($self) { sum map { $_->weight } $self->states->@* },
	init_arg => undef,
	clearer => 1,
);

sub collapse($self)
{
	return $self->_collapsed_state;
}

sub is_collapsed($self)
{
	return $self->_is_collapsed;
}

sub weight_sum($self)
{
	return $self->_weight_sum;
}

sub reset($self)
{
	foreach my $state ($self->states->@*) {
		$state->reset;
	}
	$self->_reset;
}

sub _observe($self)
{
	my @positions = $self->states->@*;
	my $sum = $self->weight_sum;
	my $prop = get_rand;

	foreach my $state (@positions) {
		$prop -= $state->weight / $sum;
		return $state->get_value if $prop < 0;
	}
}

sub _build_eigenstates($self)
{
	my %eigenstates;
	for my $state ($self->states->@*) {
		my @local_eigenstates;
		my $coeff = 1;

		if (is_collapsible $state->get_value) {
			# all values from this state must have their weights multiplied by $coeff
			# this way the weight sum will stay the same
			$coeff = $state->weight / $state->get_value->weight_sum;
			@local_eigenstates = $state->get_value->eigenstates->@*;
		} else {
			@local_eigenstates = $state;
		}

		foreach my $value (@local_eigenstates) {
			my $result = $value->get_value;
			my $propability = $value->weight * $coeff;

			if (exists $eigenstates{$result}) {
				$eigenstates{$result}[0] += $propability;
			} else {
				$eigenstates{$result} = [$propability, $result];
			}
		}
	}

	return [values %eigenstates];
}

1;
