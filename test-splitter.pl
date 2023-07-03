#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use lib '/home/ben/projects/lingua-ja-name-splitter/lib';
use Lingua::JA::Name::Splitter qw!split_kanji_name kkname!;

binmode STDOUT, ":utf8";
# read the file into a local variable.

my @inputs;
open my $in, "<:utf8", 'split-names.txt' or die $!;
while (<$in>) {
    chomp;
    my ($name, $surname, $given) = split /\s/, $_;
    if (! kkname ($name)) {
	next;
    }
    push @inputs, [$name, $surname, $given];
}
close $in or die $!;

my $count = 0;
my $max = 100;
my $best = 0;
my $bestw;
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
    print "$weight: OK: $results{ok}, wrong: $results{bad}\n";
    if ($results{ok} > $best) {
	$best = $results{ok};
	$bestw = $weight;
    }
}
print "The best weight was $bestw with $best OK results.\n";
