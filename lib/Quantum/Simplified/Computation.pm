package Quantum::Simplified::Computation;

our $VERSION = '1.00';

use Modern::Perl "2017";
use Moo;

use feature qw(signatures);
no warnings qw(experimental::signatures);

use Quantum::Simplified::Operation::MathOp;
use Quantum::Simplified::Util qw(is_collapsible);
use Types::Common::Numeric qw(PositiveNum);
use Types::Standard qw(ConsumerOf ArrayRef Str);

use namespace::clean;

with "Quantum::Simplified::Role::Collapsible";

has "operation" => (
	is => "ro",
	isa => (ConsumerOf["Quantum::Simplified::Role::Operation"])
		->plus_coercions(Str, q{Quantum::Simplified::Operation::MathOp->new(sign => $_)}),
	coerce => 1,
	required => 1,
);

has "values" => (
	is => "ro",
	isa => ArrayRef->where(q{@$_ > 0}),
	required => 1,
);

sub weight_sum { 1 }

sub collapse($self)
{
	my @members = map {
		(is_collapsible $_) ? $_->collapse : $_
	} $self->values->@*;

	return $self->operation->run(@members);
}

sub is_collapsed($self)
{
	# a single uncollapsed state means that the computation
	# is not fully collapsed
	foreach my $member ($self->values->@*) {
		if (is_collapsible($member) && !$member->is_collapsed) {
			return 0;
		}
	}
	return 1;
}

sub reset($self)
{
	foreach my $member ($self->values->@*) {
		if (is_collapsible $member) {
			$member->reset;
		}
	}
}

sub _cartesian_product($self, $values1, $values2)
{
	my %states;
	for my $val1 ($values1->@*) {
		for my $val2 ($values2->@*) {
			my $result = $self->operation->run($val1->[1], $val2->[1]);
			my $propability = $val1->[0] * $val2->[0];

			if (exists $states{$result}) {
				$states{$result}[0] += $propability
			} else {
				$states{$result} = [$propability, $result];
			}
		}
	}

	return [values %states];
}

sub _build_complete_states($self)
{
	my $states;
	for my $value ($self->values->@*) {
		my $local_states;

		if (is_collapsible $value) {
			my $total = $value->weight_sum;
			$local_states = [map {
				[$_->weight / $total, $_->get_value]
			} $value->states->@*];
		} else {
			$local_states = [[1, $value]];
		}

		if (defined $states) {
			$states = $self->_cartesian_product($states, $local_states);
		} else {
			$states = $local_states;
		}
	}

	return $states;
}

1;

