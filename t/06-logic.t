use Modern::Perl "2017";
use Test::More;
use Quantum::Simplified;
use Data::Dumper;

##############################################################################
# This test checks if comparison operators are returning the right thing when
# used on superpos states.
##############################################################################

my $pos1 = superpos(1, 2, 3);
my $pos2 = superpos(3, 4, 5);
my $pos3 = superpos(4, 5, 6);

ok $pos1 == $pos2, "superpositions numeric eq ok";
ok $pos1 != $pos3, "superpositions numeric ne ok";
ok $pos1 eq $pos2, "superpositions eq ok";
ok $pos1 ne $pos3, "superpositions ne ok";

ok any_state { $pos1 == 1 };
ok any_state { $pos1 != 2.5 };
ok any_state { $pos1 != 0 };

ok every_state { $pos1 != 20 };
ok !every_state { $pos1 == 2 };
ok every_state { $pos1 != $pos3 };

done_testing;
