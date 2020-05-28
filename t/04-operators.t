use Modern::Perl "2017";
use Test::More;
use Quantum::Simplified;

##############################################################################
# Here we're checking if other operators than plus also yield the
# right results, but we don't care for the collapsing stuff anymore
##############################################################################

my $a1 = superpos(6);
my $a2 = superpos(3);

is "$a1", 6, "stringification ok";
is ($a1 . $a2, 63, "concatenation ok");

is (($a1 - $a2)->collapse, 3, "subtraction ok");
is (($a1 * $a2)->collapse, 18, "multiplication ok");
is (($a1 / $a2)->collapse, 2, "division ok");
is (($a1 % $a2)->collapse, 0, "modulo ok");


done_testing;
