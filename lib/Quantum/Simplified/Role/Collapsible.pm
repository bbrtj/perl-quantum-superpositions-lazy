package Quantum::Simplified::Role::Collapsible;

our $VERSION = '1.00';

use Modern::Perl "2017";
use Moo::Role;

use feature qw(signatures);
no warnings qw(experimental::signatures);

use Quantum::Simplified::Computation;
use Quantum::Simplified::State;
use Quantum::Simplified::Computation::LogicOp;
use Types::Standard qw(ArrayRef InstanceOf);

my %mathematical = map { $_ => 1 } qw(
	+ - * / %
);

my %logical = map { $_ => 1 } qw(
	== != eq ne
);

sub create_computation($type, @args)
{
	return Quantum::Simplified::Computation->new(
		operation => $type,
		values => [@args],
	);
}

sub compare_eigenstates($type, @args)
{
	my $reducer = do { no strict "vars"; $QS_reducer_type };
	my $op = Quantum::Simplified::Computation::LogicOp->new(
		sign => $type,
		(defined $reducer ? (reducer => $reducer) : ())
	);

	return $op->run(@args);
}

sub operate(@args)
{
	my $type = pop @args;
	pop @args; # discard the order

	if ($mathematical{$type}) {
		return create_computation $type, @args;
	}

	elsif ($logical{$type}) {
		return compare_eigenstates $type, @args;
	}

	else {
		...
	}

}

sub stringify($value, @)
{
	return $value->collapse;
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

use overload
	q{nomethod} => \&operate,

	q{""} => \&stringify,
;

1;
