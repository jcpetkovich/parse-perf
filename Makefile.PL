use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Parse::Perf',
    AUTHOR           => q{Jean-Christophe Petkovich <jcpetkovich@gmail.com>},
    VERSION_FROM     => 'lib/Parse/Perf.pm',
    ABSTRACT_FROM    => 'lib/Parse/Perf.pm',
    LICENSE          => 'Artistic_2_0',
    PL_FILES         => {},
    EXE_FILES        => [ 'parse-perf', 'merge-results' ],
    MIN_PERL_VERSION => 5.012,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'Text::CSV' => 1.15,
        'File::Find::Rule' => 0.33,
        'Try::Tiny' => 0.12,
        'Archive::Any' =>  0.0932,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Parse-Perf-*' },
);
