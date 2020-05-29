use Modern::Perl "2017";
use Test::More;
use Quantum::Simplified;
use Data::Dumper;

##############################################################################
# Assertions of produced eigenstates. A list of every possible outcome should
# be produced, along with their propabilities. Duplicated values should be
# merged where possible.
##############################################################################

sub check_propability
{
	my ($state, $prop) = @_;

	# we'll be comparing with three digit precision, so add those in case they're not there
	my $state_weight = $state->weight . ".000";
	is substr($state_weight, 0, length $prop), $prop, "state propability ok";
}

sub test_states
{
	my ($wanted, $states) = @_;

	is scalar @$states, scalar keys %$wanted, "states count ok";
	foreach my $state (@$states) {
		my $prop = $wanted->{$state->get_value};
		ok defined $prop, "state value ok";
		check_propability($state, $prop);
	}
}

my $pos = superpos(6, 5, 4);

SIMPLE_TEST: {
	my %wanted = map { $_ => "1.000" } 6, 5, 4;
	my @states = $pos->eigenstates->@*;

	test_states(\%wanted, \@states);
}

TEST_PLUS_SCALAR: {
	my $comp = $pos * 2;
	my %wanted = map { $_ => "0.333" } 12, 10, 8;
	my @states = $comp->eigenstates->@*;

	test_states(\%wanted, \@states);
}

TEST_PLUS_SUPERPOS: {
	my $comp = $pos * superpos(2, 3);
	my %wanted = (
		18 => "0.166",
		15 => "0.166",
		12 => "0.333",
		10 => "0.166",
		8 => "0.166",
	);
	my @states = $comp->eigenstates->@*;

	test_states(\%wanted, \@states);
}

TEST_NESTED_IN_STATE: {
	my $complex_pos = superpos([6, $pos * superpos(2, 3)], [5, 2], [3, 3], [2, 18]);
	my %wanted = (
		18 => "3.000",
		15 => "1.000",
		12 => "2.000",
		10 => "1.000",
		8 => "1.000",
		2 => "5.000",
		3 => "3.000",
	);
	my @states = $complex_pos->eigenstates->@*;

	test_states(\%wanted, \@states);
}

done_testing;
