package Quantum::Simplified;

our $VERSION = '1.00';

use Modern::Perl "2017";
use feature qw(signatures);
no warnings qw(experimental::signatures);

use Quantum::Simplified::Superposition;
use Quantum::Simplified::Computation::LogicOp;

use Exporter qw(import);

our @EXPORT = qw(
	superpos
	any_state
	every_state
	one_state
	meets_condition
);

our $global_reducer_type = "any";
our $global_compare_bool = 1;

sub _run_sub_as($sub, $reducer_type = undef, $compare_type = undef)
{
	local $global_reducer_type = $reducer_type // $global_reducer_type;
	local $global_compare_bool = $compare_type // $global_compare_bool;
	return $sub->();
}

sub superpos(@positions)
{
	return Quantum::Simplified::Superposition->new(
		states => [@positions]
	);
}

sub any_state :prototype(&) ($sub)
{
	return _run_sub_as $sub, "any";
}

sub every_state :prototype(&) ($sub)
{
	return _run_sub_as $sub, "all";
}

sub one_state :prototype(&) ($sub)
{
	return _run_sub_as $sub, "one";
}

sub meets_condition :prototype(&) ($sub)
{
	return _run_sub_as $sub, undef, 0;
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
