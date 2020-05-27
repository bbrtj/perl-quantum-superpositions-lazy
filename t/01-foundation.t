use Modern::Perl "2017";
use Test::More;
use constant MAX_TRIES => 50;

##############################################################################
# This test checks if the correct class for superpositions is constructed and
# if the superpositions are able to create their basic function which is
# collapsing to a random state that they are made of
##############################################################################

BEGIN { use_ok('Quantum::Simplified') };

my $pos = suppos(1);

isa_ok($pos, "Quantum::Simplified::Superposition", "class constructed ok");
is $pos->collapse, 1, "collapsing a single value ok";

my $superpos = suppos(1, 2, 3, 4);
my %unseen = map { $_->value => 1 } $superpos->states->@*;
my %seen;

is scalar keys %unseen, 4, "value count in positions ok";

for (0 .. MAX_TRIES) {
	my $collapsed = $superpos->collapse;
	ok $superpos->is_collapsed, "superposition collapsed ok";

	delete $unseen{$collapsed};
	$seen{$collapsed} = 1;
	last if keys %unseen == 0;

	$superpos->reset;
	ok !$superpos->is_collapsed, "superposition reset ok";
}

is scalar keys %seen, 4, "value count in positions ok";

done_testing;
