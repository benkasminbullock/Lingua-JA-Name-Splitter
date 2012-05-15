#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Lingua::JA::Moji ':all';
use FindBin;
my $input = "$FindBin::Bin/enamdict";
open my $in, "<:encoding(EUC-JP)", $input or die $!;
binmode STDOUT, ":utf8";
my %given;
my %family;
my $kanji_re = qr/
                     (
                         (?:
                             \p{InCJKUnifiedIdeographs}
                         |
                             \p{InCJKSymbolsAndPunctuation}
                         |
                             \p{InHiragana}
                         |
                             \p{InKatakana}
                         |
                             \p{InWideAscii}
                         )+
                     )
                 /x;

my $pron_re = qr/
                    \s*\[
                    (?:
                        \p{InHiragana}
                    |
                        \p{InKatakana}
                    )+
                    \]\s*
                /x;

my $type_re = qr!
                    \s*/.*?\(([a-z,]+)\).*?/\s*
                !x;

while (<$in>) {
    if (m!^
          $kanji_re
          $pron_re
          $type_re
          $
         !x) {
        my $kanji = $1;
        my $type = $2;
        do_types ($kanji, $type);
    }
    elsif (m!
                \p{InKana}+
                $pron_re
                $type_re
            !x) {
        next;
    }
    elsif (m!
                ^
                \p{InKana}+
.*
                $
            !x) {
        next;
    }
    elsif (m!\(p\)!) {
        # Don't care about place names.
        next;
    }
    else {
        #        print "No match $_\n";
    }
}
close $in or die $!;
my $minimum = 20;
my %all;
@all{keys %given} = (1) x scalar (keys %given);
@all{keys %family} = (1) x scalar (keys %family);
for my $kanji (sort keys %all) {
    if ($kanji !~ /\p{InCJKUnifiedIdeographs}/) {
        next;
    }
    if (! defined $given{$kanji}) {
        $given{$kanji} = 0;
    }
    if (! defined $family{$kanji}) {
        $family{$kanji} = 0;
    }
    my $total = $given{$kanji} + $family{$kanji};
    if ($total > $minimum) {
        my $prob = $family{$kanji} / $total;
#        print "$kanji: $prob (Given: $given{$kanji} / Family: $family{$kanji})\n";
        printf "$kanji %.4f\n", $prob;
    }
}
exit ();


sub do_types
{
    my ($kanji, $type) = @_;
    my @kanji = split '', $kanji;
    my @types = split /,/, $type;
    for my $type (@types) {
        if ($type eq 'f' || $type eq 'm' || $type eq 'g') {
            for my $k (@kanji) {
                $given{$k}++;
            }
        }
        elsif ($type eq 's') {
            for my $k (@kanji) {
                $family{$k}++;
            }
        }
#        elsif ($type eq 'h') {
#            print "Full name '$kanji'\n";
#        }
    }
}
