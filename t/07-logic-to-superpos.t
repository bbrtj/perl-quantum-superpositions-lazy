use Modern::Perl "2017";
use Test::More;
use Quantum::Simplified;
use Data::Dumper;
use lib 't/lib';
use StateTesters;

##############################################################################
##############################################################################

my $pos1 = superpos(1, 2, [8, 3], [7, 4], 100);
my $pos2 = superpos(3, 4, 5, 100);

CONTAINS: {
	my $pos3 = meets_condition { $pos1 == $pos2 };
	my %wanted = (
		3 => "8.000",
		4 => "7.000",
		100 => "1.000",
	);

	isa_ok $pos3, "Quantum::Simplified::Superposition";
	test_states(\%wanted, $pos3->eigenstates);
}

done_testing;
