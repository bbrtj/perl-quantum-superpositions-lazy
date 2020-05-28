package Quantum::Simplified::Superposition;

our $VERSION = '1.00';

use Modern::Perl "2017";
use Moo;

use feature qw(signatures);
no warnings qw(experimental::signatures);

use Quantum::Simplified::State;
use Quantum::Simplified::Computation;
use Quantum::Simplified::Util qw(get_rand);
use Types::Standard qw(ArrayRef InstanceOf);
use List::Util qw(sum);

use namespace::clean;

with "Quantum::Simplified::Roles::Collapsible";

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
);

has "_weight_sum" => (
	is => "ro",
	lazy => 1,
	default => sub ($self) { sum map { $_->weight } $self->states->@* },
	init_arg => undef,
);

sub collapse($self)
{
	return $self->_collapsed_state;
}

sub is_collapsed($self)
{
	return $self->_is_collapsed;
}

sub _observe($self)
{
	my @positions = $self->states->@*;
	my $sum = $self->_weight_sum;
	my $prop = get_rand;

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

1;
