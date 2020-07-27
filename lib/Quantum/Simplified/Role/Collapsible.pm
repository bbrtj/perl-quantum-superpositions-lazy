package Quantum::Simplified::Role::Collapsible;

our $VERSION = '1.00';

use v5.24; use warnings;
use Moo::Role;

use feature qw(signatures);
no warnings qw(experimental::signatures);

use Quantum::Simplified::Operation::MathOp;
use Quantum::Simplified::Operation::LogicOp;
use Quantum::Simplified::Computation;
use Quantum::Simplified::State;
use Quantum::Simplified::Statistics;
use Types::Standard qw(ArrayRef InstanceOf);
use List::Util qw(reduce);
use Carp qw(croak);

my %mathematical = map { $_ => 1 }
	Quantum::Simplified::Operation::MathOp->supported_types;

my %logical = map { $_ => 1 }
	Quantum::Simplified::Operation::LogicOp->supported_types;

sub create_computation($type, @args)
{
	return Quantum::Simplified::Computation->new(
		operation => $type,
		values => [@args],
	);
}

sub create_logic($type, @args)
{
	my $op = Quantum::Simplified::Operation::LogicOp->new(
		sign => $type,
	);

	if ($Quantum::Simplified::global_compare_bool) {
		return $op->run(@args);
	} else {
		return $op->valid_states(@args);
	}
}

sub _operate(@args)
{
	my $type = pop @args;

	my $self = shift @args;
	return $self->operate($type, @args);
}



use namespace::clean;

requires qw(
	collapse
	is_collapsed
	_build_complete_states
	weight_sum
	reset
);

has "_complete_states" => (
	is => "ro",
	isa => ArrayRef[
		(InstanceOf["Quantum::Simplified::State"])
			->plus_coercions(
				ArrayRef->where(q{@$_ == 2}), q{ Quantum::Simplified::State->new(weight => shift @$_, value => shift @$_) },
			)
	],
	lazy => 1,
	coerce => 1,
	builder => "_build_complete_states",
	clearer => "clear_states",
	init_arg => undef,
);

has "stats" => (
	is => "ro",
	isa => InstanceOf["Quantum::Simplified::Statistics"],
	lazy => 1,
	default => sub ($self) { Quantum::Simplified::Statistics->new(parent => $self) },
	init_arg => undef,
	clearer => "_clear_stats",
);

sub states($self)
{
	return $self->_complete_states;
}

sub stringify($self, @)
{
	return $self->collapse;
}

sub operate($self, $type, @args)
{
	unshift @args, $self;
	my $order = pop @args;
	@args = reverse @args
		if $order;

	if ($mathematical{$type}) {
		return create_computation $type, @args;
	}

	elsif ($logical{$type}) {
		return create_logic $type, @args;
	}

	else {
		croak "quantum operator $type is not supported";
	}
}

sub to_ket_notation($self)
{
	return join " + ", map {
		($_->weight / $self->weight_sum) . "|" .
		$_->value . ">"
	} $self->states->@*;
}

use overload
	q{nomethod} => \&_operate,
	q{fallback} => 0,

	q{=} => sub { shift },
	q{""} => \&stringify,
;

1;
