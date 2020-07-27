use 5.024000;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME => 'Quantum::Simplified',
	MIN_PERL_VERSION => '5.024',
	VERSION_FROM => 'lib/Quantum/Simplified.pm',

	TEST_REQUIRES => {
		'Test::Exception' => 0,
		'Mock::Sub' => 0,
	},

	PREREQ_PM => {
		"namespace::clean" => 0,
		"Moo" => 0,
		"Type::Tiny" => 0,
		"List::MoreUtils" => 0,
		"Data::Entropy" => 0,
		"Sort::Key" => 0,
	},

	ABSTRACT_FROM => 'lib/Quantum/Simplified.pm',
	AUTHOR => 'Bartosz Jarzyna <brtastic.dev@gmail.com>',
	LICENSE => 'perl',
);
