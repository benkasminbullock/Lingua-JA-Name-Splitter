#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Enamdict 'parse_enamdict';

my %given;
my %surname;
my %full;

binmode STDOUT, ":utf8";

parse_enamdict (
    kanji_callback => \& kanji_callback,
);

printf "%d %d %d\n", scalar keys %given, scalar keys %full, scalar keys %surname;
my $count = 0;
open my $out, ">:utf8", 'split-names.txt' or die $!;

for my $n (keys %full) {
    for my $split (1..length ($n) - 1) {
        my $surname = substr ($n, 0, $split);
        my $given = substr ($n, $split, length $n);
        if ($surname{$surname} && $given{$given}) {
            print $out "$n $surname $given\n";
        }
    }
    $count++;
    if ($count > 10) {
#        exit;
    }
}

close $out or die $!;

exit;

sub kanji_callback
{
    my ($kanji, $kana, $type) = @_;
    my @types = split /,/, $type;
    my %types;
    @types{@types} = @types;
    if ($types{s}) {
        $surname{$kanji} = $kana;
#        print "Surname: $kanji $kana $type\n";
    }
    if ($types{m} || $types{f} || $types{g}) {
        $given{$kanji} = $kana;
#        print "Given: $kanji $kana $type\n";
    }
    if ($types{h}) {
        $full{$kanji} = $kana;
#        print "Full: $kanji $kana $type\n";
    }
}
