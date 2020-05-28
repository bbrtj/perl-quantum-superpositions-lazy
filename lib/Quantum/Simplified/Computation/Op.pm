package Quantum::Simplified::Computation::Op;

our $VERSION = '1.00';

use Modern::Perl "2017";
use Moo;

use feature qw(signatures);
no warnings qw(experimental::signatures);

use Types::Standard qw(Enum);
use Carp qw(croak);

use namespace::clean;

my %types = (
	q{+} => [2, sub {$a + $b}],
	q{-} => [2, sub {$a - $b}],
	q{*} => [2, sub {$a * $b}],
	q{/} => [2, sub {$a / $b}],
	q{%} => [2, sub {$a % $b}],
	q{.} => [2, sub {$a . $b}],
);

has "sign" => (
	is => "ro",
	isa => Enum[keys %types],
	required => 1,
);

sub run($self, @parameters)
{
	my ($param_num, $code) = $types{$self->sign}->@*;

	croak "invalid number of parameters to " . $self->sign
		unless @parameters == $param_num;

	local ($a, $b) = @parameters;
	return $code->();
}

1;
