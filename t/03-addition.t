use Modern::Perl "2017";
use Test::More;
use Quantum::Simplified;

##############################################################################
# Here we're checking if it is possible to entangle a couple of states in
# a mathematical equation, so that they act as a single system and collapse
# all at once (and reset all at once too). We use single addition for this.
##############################################################################

my $a1 = suppos(2, 3, 4);
my $a2 = suppos(5, 0, -1);

my $sum = $a1 + $a2;

ok !$sum->is_collapsed, "not collapsed before looking ok";
note "collapsed into: " . $sum->collapse;

ok $a1->is_collapsed && $a2->is_collapsed, "equation elements have collapsed";
is $sum->collapse, $a1->collapse + $a2->collapse, "sum ok";

$sum->reset;
ok !$sum->is_collapsed
	&& !$a1->is_collapsed
	&& !$a2->is_collapsed, "system reset ok";

my $plus2 = 1 + $sum + 1;
is $plus2->collapse, $sum->collapse + 2, "sum with constant ok";
note "collapsed into: " . $sum->collapse;

done_testing;
