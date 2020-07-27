use v5.24; use warnings;
use Test::More;
use Mock::Sub;
use Quantum::Simplified::Util;

my $rand;

BEGIN {
	$rand = Mock::Sub->new->mock("Quantum::Simplified::Util::get_rand");
	eval "use Quantum::Simplified";
}

##############################################################################
# This test tries to check if the weights specified at the creation of a
# superposition are used in the collapsing of the quantum state.
##############################################################################

my $superpos = superpos([1 => 1], [3 => 2]);

for my $state ($superpos->_states->@*) {
	if ($state->value eq 1) {
		is $state->weight, 1, "weight ok";
	} elsif ($state->value eq 2) {
		is $state->weight, 3, "weight ok";
	} else {
		fail "unexpected value in quantum states";
	}
}

for my $num (0 .. 10) {
	$rand->return_value($num / 10);
	my $collapsed = $superpos->collapse;
	note Quantum::Simplified::Util::get_rand . " - $collapsed";

	is $collapsed, ($num <= 2 ? 1 : 2), "value weight ok";
	$superpos->reset;
}

done_testing;
