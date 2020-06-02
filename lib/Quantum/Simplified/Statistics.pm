package Quantum::Simplified::Statistics;

our $VERSION = '1.00';

use Modern::Perl "2017";
use Moo;

use feature qw(signatures);
no warnings qw(experimental::signatures);

use Quantum::Simplified::Role::Collapsible;
use Quantum::Simplified::State;
use Types::Standard qw(ArrayRef ConsumerOf InstanceOf);
use Sort::Key qw(keysort nkeysort);
use List::Util qw(sum);

# This approximation should be well within the range of 32 bit
# floating point values - 6 digits (IEEE 754)
use constant HALF_APPROX => "0.500000";

sub transform_states($items, $transformer)
{
	my @transformed = map {
		Quantum::Simplified::State->new(
			weight => $_->weight,
			value => $transformer->($_->value),
		)
	} @$items;

	return \@transformed;
}

sub weight_to_probability($item, $weight_sum)
{
	return Quantum::Simplified::State->new(
		weight => $item->weight / $weight_sum,
		value => $item->value
	) if defined $item;

	return $item;
}

sub weighted_mean($list_ref, $weight_sum = undef)
{
	$weight_sum = sum map { $_->weight } $list_ref->@*
		unless defined $weight_sum;

	my @values = map { $_->value * $_->weight / $weight_sum } $list_ref->@*;
	return sum @values;
}

# The sorting order is irrelevant here
sub weighted_median($sorted_list_ref, $average = 0)
{
	my $approx_half = sub ($value) {
		return HALF_APPROX eq substr(($value . (0 x length HALF_APPROX)), 0, length HALF_APPROX);
	};

	my $running_sum = 0;
	my $last_el;
	my @found;

	for my $el ($sorted_list_ref->@*) {
		$running_sum += $el->weight;

		if ($running_sum > 0.5) {
			push @found, $last_el if $approx_half->($running_sum - $el->weight);
			push @found, $el;
			last;
		}

		$last_el = $el;
	}

	# if we're allowed to average the result, do that
	return weighted_mean(\@found)
		if $average;

	# get the lowest weight value if we can't average the two
	# be biased towards the first value
	return $found[1]->weight < $found[0]->weight ? $found[1]->value : $found[0]->value
		if @found == 2;

	return @found > 0 ? $found[0]->value : undef;
}

# CAUTION: float == comparison inside. Will only work for elements
# that were obtained in a similar fasion
sub find_border_elements($sorted) {
	my @found;
	for my $state (@$sorted) {
		push @found, $state
			if @found == 0 || $found[-1]->weight == $state->weight;
	}

	return \@found;
}

my %options = (
	is => "ro",
	lazy => 1,
	init_arg => undef,
);

use namespace::clean;

has "parent" => (
	is => "ro",
	isa => ConsumerOf["Quantum::Simplified::Role::Collapsible"],
	weak_ref => 1,
);

# Sorted in ascending order
has "sorted_by_probability" => (
	%options,
	isa => ArrayRef[InstanceOf["Quantum::Simplified::State"]],
	default => sub ($self) {
		[
			map {
				weight_to_probability($_, $self->parent->weight_sum)
			} nkeysort {
				$_->weight
			} $self->parent->states->@*
		]
	},
);

# Sorted in ascending order
# (we use sorted_by_probability to avoid copying states twice in weight_to_probability)
has "sorted_by_value_str" => (
	%options,
	isa => ArrayRef[InstanceOf["Quantum::Simplified::State"]],
	default => sub ($self) {
		[
			keysort { $_->value }
				$self->sorted_by_probability->@*
		]
	},
);

has "sorted_by_value_num" => (
	%options,
	isa => ArrayRef[InstanceOf["Quantum::Simplified::State"]],
	default => sub ($self) {
		[
			nkeysort { $_->value }
				$self->sorted_by_probability->@*
		]
	},
);

# Other consumer indicator
has "most_probable" => (
	%options,
	isa => InstanceOf["Quantum::Simplified::Superposition"],
	default => sub ($self) {
		my @sorted = reverse $self->sorted_by_probability->@*;
		return Quantum::Simplified::Superposition->new(
			states => find_border_elements(\@sorted)
		);
	},
);

has "least_probable" => (
	%options,
	isa => InstanceOf["Quantum::Simplified::Superposition"],
	default => sub ($self) {
		my $sorted = $self->sorted_by_probability;
		return Quantum::Simplified::Superposition->new(
			states => find_border_elements($sorted)
		);
	},
);

has "median_str" => (
	%options,
	default => sub ($self) {
		weighted_median($self->sorted_by_value_str);
	},
);

has "median_num" => (
	%options,
	default => sub ($self) {
		weighted_median($self->sorted_by_value_num, 1);
	},
);

has "mean" => (
	%options,
	default => sub ($self) {
		# since the mean won't return a state, we're free not
		# to make copies of the states.
		weighted_mean($self->parent->states, $self->parent->weight_sum);
	},
);

has "variance" => (
	%options,
	default => sub ($self) {
		# transform_states is required here so that we don't modify existing states
		weighted_mean(transform_states($self->parent->states, sub { $_[0] ** 2 }), $self->parent->weight_sum)
			-
		$self->mean ** 2
	},
);

sub median($self)
{
	return $self->median_str;
}

sub expected_value($self)
{
	return $self->mean;
}

sub standard_deviation($self)
{
	return sqrt $self->variance;
}


1;

# TODO: document shifting from returned arrayrefs
