use warnings;
use strict;
use Test::More;# tests;# => 3;
BEGIN { use_ok('Lingua::JA::Name::Splitter') };
use Lingua::JA::Name::Splitter 'split_name';
use utf8;

my $builder = Test::More->builder;
binmode $builder->output,         ":utf8";
binmode $builder->failure_output, ":utf8";
binmode $builder->todo_output,    ":utf8";

# Local variables:
# mode: perl
# End:

my %names = (
    鈴木太郎 => 2,
    福田雅樹 => 2,
    市塚ひろ子 => 2,
    団令子 => 1,
);

for my $name (keys %names) {
    my ($family, $given) = split_name ($name);
    ok (length $family eq $names{$name}, "Got $family from $name as expected");
    ok (length ($family) + length ($given) == length ($name),
        "Right name lengths");
}
done_testing ();
