package Quantum::Simplified::Operation::LogicOp;

our $VERSION = '1.00';

use Modern::Perl "2017";
use Moo;

use feature qw(signatures);
no warnings qw(experimental::signatures);

use Quantum::Simplified::Superposition;
use Quantum::Simplified::Util qw(is_collapsible is_state);
use Types::Standard qw(Enum);
use List::MoreUtils qw(zip);
use Carp qw(croak);

my %types = (
	# type => number of parameters, code
	q{==} => [2, sub {$a == $b}],
	q{!=} => [2, sub {$a != $b}],
	q{eq} => [2, sub {$a eq $b}],
	q{ne} => [2, sub {$a ne $b}],
);

my %reducer_types = (
	# type => short circuit value, code
	q{all} => [0, sub { ($a // 1) && $b }],
	q{any} => [1, sub { $a || $b }],
);

sub extract_state($ref, $index = undef)
{
	my $values = is_collapsible($ref) ? $ref->states : [$ref];

	return $values unless defined $index;
	return $values->[$index];
}

sub get_iterator(@parameters)
{
	my @states = map { extract_state($_) } @parameters;
	my @indexes = map { 0 } @parameters;
	my @max_indexes = map { $#$_ } @states;

	my $finished = 0;
	return sub ($with_indexes = 0) {
		return if $finished;

		my $i = 0;
		my @ret =
			map { is_state($_) ? $_->get_value : $_ }
			map { $states[$i++][$_] }
			@indexes;

		if ($with_indexes) {
			@ret = zip @indexes, @ret;
		}

		$i = 0;
		while ($i < @indexes && ++$indexes[$i] > $max_indexes[$i]) {
			$indexes[$i] = 0;
			$i += 1;
		}

		$finished = $i == @indexes;
		return @ret;
	};
}

use namespace::clean;

with "Quantum::Simplified::Role::Operation";

has "+sign" => (
	is => "ro",
	isa => Enum[keys %types],
	required => 1,
);

has "reducer" => (
	is => "ro",
	isa => Enum[keys %reducer_types],
	writer => "set_reducer",
	default => sub { $Quantum::Simplified::global_reducer_type },
);

sub supported_types($self)
{
	return keys %types;
}

sub run($self, @parameters)
{
	my ($param_num, $code) = $types{$self->sign}->@*;

	croak "invalid number of parameters to " . $self->sign
		unless @parameters == $param_num;

	my $carry;
	my $reducer = $reducer_types{$self->reducer};
	my $iterator = get_iterator @parameters;

	local ($a, $b);
	while (($a, $b) = $iterator->()) {
		# $a and $b are set up for type sub
		$b = $code->();
		$a = $carry;

		# $a and $b are set up for reducer sub
		$carry = $reducer->[1]();

		# short circuit if possible
		return $carry if !!$carry eq !!$reducer->[0];
	}

	return !!$carry;
}

sub valid_states($self, @parameters)
{
	my ($param_num, $code) = $types{$self->sign}->@*;

	croak "invalid number of parameters to " . $self->sign
		unless @parameters == $param_num;

	my @carry;
	my $iterator = get_iterator @parameters;

	local ($a, $b);
	my ($key_a, $key_b);
	while (($key_a, $a, $key_b, $b) = $iterator->(1)) {
		# $a and $b are set up for type sub
		my $result = $code->();

		if ($result) {
			push @carry, extract_state($parameters[0], $key_a);
		}
	}

	return Quantum::Simplified::Superposition->new(
		states => [@carry]
	);
}

1;
