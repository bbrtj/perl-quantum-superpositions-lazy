package Quantum::Superpositions::Lazy::Computation;

our $VERSION = '1.08';

use v5.24;
use warnings;
use Moo;
use Quantum::Superpositions::Lazy::Operation::Computational;
use Quantum::Superpositions::Lazy::ComputedState;
use Quantum::Superpositions::Lazy::Util qw(is_collapsible get_iterator);
use Types::Common::Numeric qw(PositiveNum);
use Types::Standard qw(ConsumerOf ArrayRef Str);
use List::Util qw(product);

use namespace::clean;

with "Quantum::Superpositions::Lazy::Role::Collapsible";

has "operation" => (
	is => "ro",
	isa => (ConsumerOf ["Quantum::Superpositions::Lazy::Role::Operation"])
		->plus_coercions(Str,
			q{Quantum::Superpositions::Lazy::Operation::Computational->new(sign => $_)}
		),
	coerce => 1,
	required => 1,
);

has "values" => (
	is => "ro",
	isa => ArrayRef->where(q{@$_ > 0}),
	required => 1,
);

sub weight_sum { 1 }

sub collapse
{
	my ($self) = @_;

	my @members = map {
		(is_collapsible $_) ? $_->collapse : $_
	} $self->values->@*;

	return $self->operation->run(@members);
}

sub is_collapsed
{
	my ($self) = @_;

	# a single uncollapsed state means that the computation
	# is not fully collapsed
	foreach my $member ($self->values->@*) {
		if (is_collapsible($member) && !$member->is_collapsed) {
			return 0;
		}
	}
	return 1;
}

sub reset
{
	my ($self) = @_;

	foreach my $member ($self->values->@*) {
		if (is_collapsible $member) {
			$member->reset;
		}
	}

	return $self;
}

sub _cartesian_product
{
	my ($self, $input_states, $sourced) = @_;

	my %states;
	my $iterator = get_iterator $input_states->@*;

	while (my @params = $iterator->()) {
		my @source = map { $_->[1] } @params;
		my $result = $self->operation->run(@source);
		my $probability = product map { $_->[0] } @params;

		if (exists $states{$result}) {
			$states{$result}[0] += $probability;
		}
		else {
			$states{$result} = [
				$probability,
				$result,
			];
		}

		if ($sourced) {
			push $states{$result}[2]->@*, \@source;
		}
	}

	return [values %states];
}

sub _build_complete_states
{
	my ($self) = @_;

	my @input_states;
	for my $value ($self->values->@*) {
		my $local_states;

		if (is_collapsible $value) {
			my $total = $value->weight_sum;
			$local_states = [
				map {
					[$_->weight / $total, $_->value]
				} $value->states->@*
			];
		}
		else {
			$local_states = [[1, $value]];
		}

		push @input_states, $local_states;
	}

	my $sourced = $Quantum::Superpositions::Lazy::global_sourced_calculations;
	my $states = $self->_cartesian_product(\@input_states, $sourced);

	if ($sourced) {
		return [
			map {
				Quantum::Superpositions::Lazy::ComputedState->new(
					weight => $_->[0],
					value => $_->[1],
					source => $_->[2] // $_->[1],
					operation => $self->operation,
				)
			} $states->@*
		];
	}
	else {
		return $states;
	}

}

1;

__END__

=head1 NAME

Quantum::Superpositions::Lazy::Computation - a computation result,
superposition-like class

=head1 DESCRIPTION

Computation is a class with the same function as
L<Quantum::Superpositions::Lazy::Superposition> but different source of data. A
computation object spawns as soon as a superposition object is used with an
overloaded operator.

Much like a superposition, the computation object does not act upon its members
immediately but rather waits for a I<collapse> call, which then collapses any
computation member elements that consume the
L<Quantum::Superpositions::Lazy::Role::Collapsible> role. The I<reset> method
also calls itself on any collapsible member, which effectively resets the
entire "system" of members connected with mathematical operations.

Upon building the complete set of possible states, computations perform the
cartesian product of all the complete states of every source superposition.
This is a very costly operation that can produce millions of elements very
quickly.

Computations are almost indistinguishable from regular superpositions, so they
will not be addressed directly in the rest of the documentation. Instead, any
reference to a superposition should be treated as if it also referenced the
computation.

=head1 METHODS

=head2 weight_sum

For computations, this method always returns 1. All of the returned states will
have their weights scaled from the origin to have the same "slice of the pie".

=head2 other methods

Same purpose as in L<Quantum::Superpositions::Lazy::Superposition>.

=head1 OVERLOADING

Same as L<Quantum::Superpositions::Lazy::Superposition>.

