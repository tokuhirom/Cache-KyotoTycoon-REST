use inc::Module::Install;
name 'Cache-KyotoTycoon-REST';
all_from 'lib/Cache/KyotoTycoon/REST.pm';

requires 'HTTP::Date';
requires 'WWW::Curl::Easy';
requires 'URI::Escape';
requires 'Storable';

test_requires 'File::Which';
test_requires 'Test::TCP';

readme_markdown_from 'lib/Cache/KyotoTycoon/REST.pm';
tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';
test_requires 'Test::More' => 0.96; # done_testing, subtest
author_tests('xt');
WriteAll;
