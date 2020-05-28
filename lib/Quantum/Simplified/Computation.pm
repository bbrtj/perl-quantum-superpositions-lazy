package Quantum::Simplified::Computation;

our $VERSION = '1.00';

use Modern::Perl "2017";
use Moo;

use feature qw(signatures);
no warnings qw(experimental::signatures);

use Quantum::Simplified::Computation::Op;
use Types::Common::Numeric qw(PositiveNum);
use Types::Standard qw(InstanceOf ArrayRef Str);
use Carp qw(croak);
use Scalar::Util qw(blessed);

use namespace::clean;

extends "Quantum::Simplified::State";

has "operation" => (
	is => "ro",
	isa => (InstanceOf["Quantum::Simplified::Computation::Op"])
		->plus_coercions(Str, q{Quantum::Simplified::Computation::Op->new(sign => $_)}),
	coerce => 1,
	required => 1,
);

has "+value" => (
	is => "ro",
	isa => ArrayRef->where(q{@$_ > 0}),
	required => 1,
);

sub get_value($self)
{
	my @members = map {
		(blessed $_ && $_->isa("Quantum::Simplified::Superposition")) ?
			$_->collapse : $_
	} $self->value->@*;

	return $self->operation->run(@members);
}

sub reset($self)
{
	foreach my $member ($self->value->@*) {
		if (blessed $member && $member->DOES("Quantum::Simplified::Roles::Collapsible")) {
			$member->reset;
		}
	}
}

1;

