use strict;
use warnings;
use ExtUtils::MakeMaker;

my $pm = 'lib/Lingua/JA/Name/Splitter.pm';
my $repo = 'https://github.com/benkasminbullock/Lingua-JA-Name-Splitter';

WriteMakefile (
    NAME => 'Lingua::JA::Name::Splitter',
    VERSION_FROM => $pm,
    ABSTRACT_FROM => $pm,
    AUTHOR => 'Ben Bullock <bkb@cpan.org>',
    LICENSE => 'perl',
    PREREQ_PM => {
        'Lingua::JA::Moji' => '0.15',
    },
    META_MERGE => {
        resources => {
            repository => $repo,
            bugtracker => "$repo/issues",
        },
    },
);
