use strict;
use warnings;
use Test::More;
use Cache::KyotoTycoon::REST;

my $key = "hoge" . rand();
my $rest = Cache::KyotoTycoon::REST->new();

is $rest->base, 'http://127.0.0.1:1978/', 'base';

subtest 'PUT' => sub {
    $rest->put($key, "fuga1", 100);
    ok 1;
};

subtest 'GET' => sub {
    is scalar($rest->get("UNKNOWN KEY!")), undef;

    is scalar($rest->get($key)), "fuga1";

    my ($content, $expires) = $rest->get($key);
    is $content, 'fuga1';
    cmp_ok abs($expires-time()-100), '<', 10;
};

subtest 'HEAD' => sub {
    my $expires = $rest->head($key);
    ok $expires;
    cmp_ok abs($expires-time()-100), '<', 10;

    is($rest->head("UNKNOWNNNNNNN"), undef);
};

subtest 'DELETE' => sub {
    is $rest->delete($key), 1, 'remove.';
    is $rest->delete($key), 0, 'removed. not found.';
};

done_testing;
