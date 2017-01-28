package Enamdict;
use parent Exporter;
our @EXPORT_OK = qw/parse_enamdict read_names/;
use warnings;
use strict;
use Carp;
use FindBin;
use Lingua::JA::Moji ':all';

our $enamdict = '/home/ben/data/edrdg/enamdict';

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
                    (
                        (?:
                            \p{InHiragana}
                        |
                            \p{InKatakana}
                        )+
                    )
                    \]\s*
                /x;

my $type_re = qr!
                    \s*/.*?\(([a-z,]+)\).*?/\s*
                !x;

my $kanji_name_re = qr!^
                  $kanji_re
                  $pron_re
                  $type_re
                  $
                 !x;

my $kana_re = qr!^
                 \p{InKana}+
                 $pron_re
                 $type_re
                 $
                !x;

sub parse_enamdict
{
    my (%inputs) = @_;
    my $kc = $inputs{kanji_callback};
    my $input = $enamdict;
    open my $in, "<:encoding(EUC-JP)", $input or die $!;
    while (<$in>) {
        if (/$kanji_name_re/) {
            if ($kc) {
                &{$kc} ($1, $2, $3);
            }
        }
    }
    close $in or die $!;
}

sub read_names
{
    my @inputs;
    open my $in, "<:utf8", 'split-names.txt' or die $!;
    while (<$in>) {
	chomp;
	my ($name, $surname, $given) = split /\s/, $_;
	push @inputs, [$name, $surname, $given];
    }
    close $in or die $!;
    return \@inputs;
}

1;
