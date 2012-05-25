#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Lingua::JA::Name::Splitter 'split_kanji_name';

binmode STDOUT, ":utf8";
# read the file into a local variable.

my @inputs;
open my $in, "<:utf8", 'split-names.txt' or die $!;
while (<$in>) {
    chomp;
    my ($name, $surname, $given) = split /\s/, $_;
    push @inputs, [$name, $surname, $given];
}
close $in or die $!;

my $count = 0;
my $max = 100;
for my $weight_step (0..$max) {
    my $weight = 0.7 + ($weight_step / ($max * 10));
    $Lingua::JA::Name::Splitter::length_weight = $weight;
    my %results;
    for my $input (@inputs) {
        my ($name, $surname, $given) = @$input;
        my ($s, $g) = split_kanji_name ($name);
        if ($s) {
            if ($s eq $surname && $g eq $given) {
                #                print "$s $g ok\n";
                $results{ok}++;
            }
            else {
                #                print "$s $g bad\n";
                $results{bad}++;
            }
        }
        else {
            die "Bad name $name $s $g\n";
        }

        $count++;
        if ($count > 10) {
            #            exit;
        }
    }
    print "$weight: $results{ok}, $results{bad}\n";
}
