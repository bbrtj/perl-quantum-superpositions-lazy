use 5.024000;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME => 'Quantum::Simplified',
	MIN_PERL_VERSION => '5.024',
	VERSION_FROM => 'lib/Quantum/Simplified.pm',
	PREREQ_PM => {
	},
	ABSTRACT_FROM => 'lib/Quantum/Simplified.pm',
	AUTHOR => 'Bartosz Jarzyna <brtastic.dev@gmail.com>',
	LICENSE => 'perl',
);
