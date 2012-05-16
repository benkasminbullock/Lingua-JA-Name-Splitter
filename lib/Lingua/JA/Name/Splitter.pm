package Lingua::JA::Name::Splitter;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw/split_kanji_name split_romaji_name/;
use warnings;
use strict;
our $VERSION = 0.02;
use utf8;
use Carp;
use Lingua::JA::Moji ':all';

# The probabilities that these characters are part of the family name.

my %known;

my $file = __FILE__;
$file =~ s/Splitter\.pm/probabilities.txt/;
open my $in, "<:encoding(utf8)", $file or die $!;
while (<$in>) {
    my ($kanji, $prob) = split /\s/, $_;
    $known{$kanji} = $prob;
}
close $in or die $!;

sub split_kanji_name
{
    my ($kanji) = @_;
    my $given;
    my $family;
    if (! utf8::is_utf8 ($kanji)) {
        croak "Input must be in Unicode format";
    }
    if (length $kanji == 2) {
        ($given, $family) = split '', $kanji;
        goto finished;
    }

    # The weight to give the position in the kanji if it is a known
    # kanji.
    my $length_weight = 0.5;
    my @kanji = split '', $kanji;
    # Probability this is part of the family name.
    my %probability;
    $probability{$kanji[0]} = 1;
    $probability{$kanji[-1]} = 0;
    my $length = length $kanji;
    for my $i (1..$#kanji - 1) {
        my $p = 1 - $i / ($length - 1);
        my $moji = $kanji[$i];
        if (is_kana ($moji)) {
            # Hiragana cannot be part of surname.
            $p = 0;
        }
        elsif ($known{$moji}) {
            $p = $length_weight * $p + (1 - $length_weight) * $known{$moji};
        }
        $probability{$moji} = $p;
    }
    my $in_given;
    for my $kanji (@kanji) {
#        print "$kanji: $probability{$kanji}\n";
        if ($probability{$kanji} < 0.5) {
            $in_given = 1;
        }
        if ($in_given) {
            $given .= $kanji;
        }
        else {
            $family .= $kanji;
        }
    }
    finished:
    if (! wantarray ()) {
        croak "Return value is array";
    }
    return ($family, $given);
}

sub split_romaji_name
{
    my ($name) = @_;
    # If there is no space or comma, assume that this is the last name.
    if ($name !~ /\s|,/) {
        return ('', $name);
    }
    # Remove leading and trailing spaces.
    $name =~ s/^\s+|\s+$//g;
    my @parts = split /,?\s+/, $name;
    # If there are more than two parts to the name after splitting by spaces
    if (@parts > 2) {
        warn "Strange Japanese name '$name' with middle name?";
    }
    my $last;
    my $first;
    # If the last name is capitalized, or if there is a comma in the
    # name.
    if ($parts[0] =~ /^[A-Z]+$/ || $name =~ /,/) {
        $last = $parts[0];
        $first = $parts[1];
    }
    else {
        $last = $parts[1];
        $first = $parts[0];
    }
    return ($first, $last);
}

1;
