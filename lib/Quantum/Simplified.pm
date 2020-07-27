package Quantum::Simplified;

our $VERSION = '1.00';

use v5.24; use warnings;
use feature qw(signatures);
no warnings qw(experimental::signatures);

use Quantum::Simplified::Superposition;
use Quantum::Simplified::Operation::LogicOp;
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

	return Quantum::Simplified::Superposition->new(
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

Quantum::Simplified - Simple quantum computations

=head1 DESCRIPTION



=head1 AUTHOR

Bartosz Jarzyna, E<lt>brtastic.dev@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 by Bartosz

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.24.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
