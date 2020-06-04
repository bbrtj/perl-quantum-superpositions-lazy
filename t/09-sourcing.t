use Modern::Perl "2017";
use Test::More;
use Quantum::Simplified qw(with_sources);
use Data::Dumper;

##############################################################################
##############################################################################

my $case1 = superpos(2, 3);
my $case2 = superpos(10, 20);

my %sources = (
	"-8" => [[2, 10]],
	"-7" => [[3, 10]],
	"-18" => [[2, 20]],
	"-17" => [[3, 20]],
);

my $computation = $case1 - $case2;
my $states = with_sources { $computation->states };

foreach my $state ($states->@*) {
	isa_ok $state, "Quantum::Simplified::ComputedState";
	is_deeply $state->source, $sources{$state->value}, "state source ok";
	is $state->operation->sign, "-", "state sign ok";
}

$computation->clear_states;

foreach my $state ($computation->states->@*) {
	isa_ok $state, "Quantum::Simplified::State";
}

done_testing;
