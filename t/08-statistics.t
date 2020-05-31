use Modern::Perl "2017";
use Test::More;
use Quantum::Simplified;
use Data::Dumper;
use lib 't/lib';
use StateTesters;

##############################################################################
##############################################################################

my $case1 = superpos([1, 1], [2, 2], [3, 3]);
my $case2 = superpos([0.5, 100], [0.3, 200], [0.2, 300]);

# values for this should be:
# [0.5, 100], [0.3, 200], [0.2, 300]
# [1, 200], [0.6, 400], [0.4, 600]
# [1.5, 300], [0.9, 600], [0.6, 900]
#
# after merging:
# [0.5, 100], [1.3, 200], [1.7, 300]
# [0.6, 400], [1.3, 600], [0.6, 900]
#
# total propability: 1 * 6 = 6
my $case_comp = $case2 * $case1;

isa_ok $case1->stats, "Quantum::Simplified::Statistics";

MOST_PROPABLE: {
	my $item = $case_comp->stats->most_propable;

	isa_ok $item, "Quantum::Simplified::State";
	is $item->value, 300, "most propable value ok";
	# 1.7 / 6 = 0.283333
	check_propability($item, "0.283");
}

LEAST_PROPABLE: {
	my $item = $case_comp->stats->least_propable;

	isa_ok $item, "Quantum::Simplified::State";
	is $item->value, 100, "least propable value ok";
	# 0.5 / 6 = 0.083333
	check_propability($item, "0.083");
}

MEDIAN: {
	my $item = $case_comp->stats->median;

	# 300 is the mean element for the set because its weight is
	# dividing the sorted set in the middle:
	# 0.5 + 1.3 = 1.8, is less than 3
	# 0.6 + 1.3 + 0.6 = 2.5, is also less than 3
	is $item, 300, "median ok";

	$item = $case1->stats->median;
	# Here the median should be 2, because two elements will meet
	# the condition, and we choose the one with less weight
	is $item, 2, "median special case ok";

	$item = $case1->stats->median_num;
	# Here the median should be
	# (2 * 2 + 3 * 3) / 5.0 = 2.6
	# because in median_num we create a weighted mean of the values
	is $item, 2.6, "averaged median ok";
}

MEAN: {
	my $item = $case_comp->stats->mean;

	# The weighted mean should be
	# (100 * 0.5 + 200 * 1.3 + 300 * 1.7 + 400 * 0.6 + 600 * 1.3 + 900 * 0.6) / 6
	# which is 396.666667
	is substr($item, 0, 6), 396.66, "mean ok";
}

done_testing;

