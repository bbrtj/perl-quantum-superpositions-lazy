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
is $pos1 == $pos2, !!1, "result is boolean";
ok $pos1 != $pos3, "superpositions numeric ne ok";

any_state {
	ok $pos1 == 1;
	ok $pos1 != 2.5;
	ok $pos1 != 0;
};

every_state {
	ok $pos1 != 1;
	ok $pos1 != $pos2;
};


done_testing;
