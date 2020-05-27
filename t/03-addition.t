use Modern::Perl "2017";
use Test::More;
use Quantum::Simplified;
use Data::Dumper;


##############################################################################
##############################################################################

my $a1 = suppos(2, 3, 4);
my $a2 = suppos(5, 0, -1);

my $sum = $a1 + $a2;

ok !$sum->is_collapsed, "not collapsed before looking ok";
note "collapsed into: " . $sum->collapse;

ok $a1->is_collapsed && $a2->is_collapsed, "equation elements have collapsed";
is $sum->collapse, $a1->collapse + $a2->collapse, "sum ok";

done_testing;
