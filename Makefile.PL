use inc::Module::Install;

name     'Catalyst-Authentication-Store-TokyoTyrant';
all_from 'lib/Catalyst/Authentication/Store/TokyoTyrant.pm';
author   q{Craftworks <craftwork at cpan org>};
license  'perl';

build_requires('Test::More');
build_requires('Test::UseAllModules');

author_tests 'xt';

auto_install;

WriteAll;
