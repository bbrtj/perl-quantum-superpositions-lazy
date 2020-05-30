use Modern::Perl "2017";
use Test::More;
use Quantum::Simplified;

sub get_factors
{
	my ($number) = @_;

	# produce all the possible factors
	my $possible_factors = superpos(2 .. $number / 2);

	# for every state, get those that match a condition
	# (any possible factor that is present after the number is divided by any other one)
	return meets_condition { $possible_factors == ($number / $possible_factors) };
}

my %numbers = (
	# number => factors
	78 => [2, 3, 6, 13, 26, 39],
);

while (my ($number, $factors) = each %numbers) {

	# this will be a superposition of all valid factors
	my $factors_superposition = get_factors $number;

	# did we succeed?
	foreach my $factor (@$factors) {
		ok $factors_superposition == $factor, "factor $factor found ok";
	}
	is scalar $factors_superposition->states->@*, @$factors, "factors count ok";
}

done_testing;
