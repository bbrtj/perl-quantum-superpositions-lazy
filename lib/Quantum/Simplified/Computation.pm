package Quantum::Simplified::Computation;

our $VERSION = '1.00';

use Modern::Perl "2017";
use Moo;

use feature qw(signatures);
no warnings qw(experimental::signatures);

use Quantum::Simplified::Computation::Op;
use Quantum::Simplified::Util qw(is_collapsible);
use Types::Common::Numeric qw(PositiveNum);
use Types::Standard qw(InstanceOf ArrayRef Str);

use namespace::clean;

with "Quantum::Simplified::Roles::Collapsible";

has "operation" => (
	is => "ro",
	isa => (InstanceOf["Quantum::Simplified::Computation::Op"])
		->plus_coercions(Str, q{Quantum::Simplified::Computation::Op->new(sign => $_)}),
	coerce => 1,
	required => 1,
);

has "values" => (
	is => "ro",
	isa => ArrayRef->where(q{@$_ > 0}),
	required => 1,
);

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

1;

