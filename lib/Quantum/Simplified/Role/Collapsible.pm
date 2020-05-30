package Quantum::Simplified::Role::Collapsible;

our $VERSION = '1.00';

use Modern::Perl "2017";
use Moo::Role;

use feature qw(signatures);
no warnings qw(experimental::signatures);

use Quantum::Simplified::Operation::MathOp;
use Quantum::Simplified::Operation::LogicOp;
use Quantum::Simplified::Computation;
use Quantum::Simplified::State;
use Types::Standard qw(ArrayRef InstanceOf);
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

	return $op->run(@args);
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
	_build_eigenstates
	weight_sum
	reset
);

has "_eigenstates" => (
	is => "ro",
	isa => ArrayRef[
		(InstanceOf["Quantum::Simplified::State"])
			->plus_coercions(
				ArrayRef->where(q{@$_ == 2}), q{ Quantum::Simplified::State->new(weight => shift @$_, value => shift @$_) },
			)
	],
	lazy => 1,
	coerce => 1,
	builder => "_build_eigenstates",
	clearer => 1,
);

sub eigenstates($self)
{
	return $self->_eigenstates;
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

use overload
	q{nomethod} => \&_operate,

	q{""} => \&stringify,
;

1;
