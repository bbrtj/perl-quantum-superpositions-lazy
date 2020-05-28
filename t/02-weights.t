use Modern::Perl "2017";
use Test::More;
use Quantum::Simplified;
use Data::Dumper;

use constant MAX_TRIES => 100;

##############################################################################
# This test tries to check if the weights specified at the creation of a
# superposition are used in the collapsing of the quantum state.
# Of course it's extremely hard to assert random values, so we're only making
# obvious assumptions so that it doesn't fail that often.
##############################################################################

my $superpos = superpos([1 => 1], [3 => 2]);

for my $state ($superpos->states->@*) {
	if ($state->value eq 1) {
		is $state->weight, 1, "weight ok";
	} elsif ($state->value eq 2) {
		is $state->weight, 3, "weight ok";
	} else {
		fail "unexpected value in quantum states";
	}
}

my %seen;
for (0 .. MAX_TRIES) {
	my $collapsed = $superpos->collapse;

	$seen{$collapsed} += 1;

	$superpos->reset;
}

note Dumper(\%seen);
ok $seen{2} > $seen{1},
	"weights seem to be ok, but if they're not please run the test again";

done_testing;
