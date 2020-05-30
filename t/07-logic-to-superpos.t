use Modern::Perl "2017";
use Test::More;
use Quantum::Simplified;
use Data::Dumper;

##############################################################################
##############################################################################

my $pos1 = superpos(1, 2, 3, 4);
my $pos2 = superpos(3, 4, 5);
my $pos3 = meets_condition { $pos1 == $pos2 };

isa_ok $pos3, "Quantum::Simplified::Superposition";
is scalar $pos3->eigenstates->@*, 2, "count ok";

done_testing;
