package Quantum::Superpositions::Lazy;

our $VERSION = '1.00';

use v5.24; use warnings;
use feature qw(signatures);
no warnings qw(experimental::signatures);

use Quantum::Superpositions::Lazy::Superposition;
use Quantum::Superpositions::Lazy::Operation::LogicOp;
use Exporter;

our @EXPORT = qw(
	superpos
);

our @EXPORT_OK = qw(
	any_state
	every_state
	one_state
	fetch_matches
	with_sources
);

our $global_reducer_type = "any";
our $global_compare_bool = 1;
our $global_sourced_calculations = 0;

sub import
{
	for my $exported (@EXPORT) {
		push @_, $exported
			unless grep { $_ eq $exported } @_;
	}

	goto &Exporter::import;
}

sub run_sub_as($sub, %env)
{
	local $global_reducer_type = $env{reducer_type} // $global_reducer_type;
	local $global_compare_bool = $env{compare_bool} // $global_compare_bool;
	local $global_sourced_calculations = $env{sourced_calculations} // $global_sourced_calculations;
	return $sub->();
}

sub superpos(@positions)
{
	my $positions_ref;

	if (@positions == 1 && ref $positions[0] eq ref []) {
		$positions_ref = $positions[0];
	} else {
		$positions_ref = [@positions];
	}

	return Quantum::Superpositions::Lazy::Superposition->new(
		states => $positions_ref
	);
}

sub any_state :prototype(&) ($sub)
{
	return run_sub_as $sub, reducer_type => "any";
}

sub every_state :prototype(&) ($sub)
{
	return run_sub_as $sub, reducer_type => "all";
}

sub one_state :prototype(&) ($sub)
{
	return run_sub_as $sub, reducer_type => "one";
}

sub fetch_matches :prototype(&) ($sub)
{
	return run_sub_as $sub, compare_bool => 0;
}

sub with_sources :prototype(&) ($sub)
{
	return run_sub_as $sub, sourced_calculations => 1;
}

1;
__END__

=head1 NAME

Quantum::Superpositions::Lazy - Simplified quantum-like computations

=head1 SYNOPSIS

	use Quantum::Superpositions::Lazy;

	# superpos() accepts a list or an array reference
	my $position_1 = superpos(1 .. 10);
	my $position_2 = superpos(1 .. 10);

	# most standard perl operators are supported
	my $multiplication_plate = $position_1 * $position_2;

	# get something randomly
	my $random_outcome = $multiplication_plate->collapse;

=head1 DESCRIPTION

This module allows for creation of superpositions that contain a set of
possible states. A superposition is a class that tries to behave as if it was
in all of these states at once when used in regular numeric / string
operations. Any operation that involves a superposition will yield a new
superposition-like calculation object.

Superpositions can be collapsed, which happens when they are stringified or
manually upon calling the I<collapse> method. During collapsing, a random
element from all the possible outcomes is chosen and saved as a current
persistent state of a superposition. For calculations created from
superpositions, all the source superpositions are collapsed as well.

This is mostly where the quantum physics part of the module ends. The rest of
the capabilities go beyond that and allow for calculations on uncollapsed
superpositions. It's important to note that these calculations are extremely
slow by their nature. Adding one of 1000 numbers to one of another 1000 numbers
just to get one state randomly is very fast because of the optimizations made.
Doing any kind of serious calculations on this volume of data (basically a
million objects) is only valid for educational purposes, toy programs and other
kinds of not very serious work.

=head1 CAPABILITIES / FEATURES

=head2 Superpositions and calculations

=over 2

=item * quantum-like superpositions with weighted states, containing any data

=item * persistent state after collapsing, manual state clearing

=item * superposition objects can be used with most native Perl operators

=item * calculation results are objects that reference the source objects

=item * collapsing a calculation result also collapses the source superpositions

=back

=head2 Complete set of superposition states

=over 2

=item * ability to get a complete set of superposition states, together with their calculated weights (the cartesian product)

=item * exporting the states to ket notation

=item * extracting statistical data from the superpositions, like the most probable outcome or weighted mean

=item * obtaining the sources of each and every state, which is the exact set calculation parameters used to obtain it

=back

=head1 FUNCTIONS

=head2 superpos

	superpos(@data)
	superpos([@data])

Always exported. Feeds its arguments to the
L<Quantum::Superpositions::Lazy::Superposition> constructor. If the only argument is an
array reference, it is passed as-is into the constructor, resulting with a
state for every array ref element. Otherwise creates a reference out of the
arguments and passes them instead.

	# Creates 0.5|1> + 0.5|2>
	superpos(1, 2);

	# Same thing, but with explicit weights
	superpos([1, 1], [1, 2]);

	# Caution: this does not create 1|2>, but 0.5|1> + 0.5|2>
	superpos([1, 2]);

	# Any data is OK
	superpos(qw(dont eat the fish));

=head2 any_state

=head2 every_state

=head2 one_state

	any_state BLOCK
	every_state BLOCK
	one_state BLOCK

Changes the behavior of superposition logical operations inside the block to
return true if any / every / one element matches the criteria. The default
behavior is I<any>.

	my $pos = superpos(1, 2, 3);

	$pos == 1; # true
	any_state { $pos == 1 }; # true
	every_state { $pos == 1 }; # false
	one_state { $pos == 1 }; # true

=head2 fetch_matches

	fetch_matches BLOCK

Changes the behavior of superposition logical operations inside the block to
return a new superposition of left-hand superposition states that match the
criteria instead of returning a boolean. This can be used to get more data
about the superposition rather than just an information if it matches the
criteria at all.

	my $pos = superpos(1, 2, 3);

	$pos == 2; # true
	fetch_matches { $pos == 2 }; # a superposition: 1|2>

=head2 with_sources

	with_sources BLOCK

Changes the behavior of superposition mathematical operations inside the block
to also contain the sources of the calculations made. This can be helpful to
determine how the value was calculated. This is disabled by default due to the
amount of extra memory needed by the states that are created this way.

	my $calc = superpos(2, 3) * superpos(1, 2);

	# these states will now be instances of Quantum::Superpositions::Lazy::ComputedState
	my $states = with_sources { $calc->states };

	# and contain source and operation fields which will hold:
	# source - an array reference of array references in form [$val1, $val2, ... $valn]
	# operation - instance of Quantum::Superpositions::Lazy::Operation::ComputationalOp

=head1 AUTHOR

Bartosz Jarzyna, E<lt>brtastic.dev@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 by Bartosz

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.24.0 or,
at your option, any later version of Perl 5 you may have available.


=cut