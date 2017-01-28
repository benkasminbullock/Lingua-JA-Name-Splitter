#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use lib '/home/ben/projects/lingua-ja-name-splitter/lib';
use Lingua::JA::Name::Splitter 'split_kanji_name';
use Enamdict 'read_names';
my $names = read_names ();
binmode STDOUT, ":utf8";
for my $name (@$names) {
    my ($both, $family, $given) = @$name;
    my ($xfamily, $xgiven) = split_kanji_name ($both);
    if ($xfamily ne $family || $xgiven ne $given) {
	print "Fail: $both: split: $xfamily/$xgiven; actual: $family/$given\n";
    }
}

