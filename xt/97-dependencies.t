use strict;
use warnings;
use ExtUtils::MakeMaker;
use Test::Dependencies
    exclude => [qw/Test::Dependencies Catalyst::Authentication::Store::TokyoTyrant/],
    style   => 'light';

ok_dependencies();
