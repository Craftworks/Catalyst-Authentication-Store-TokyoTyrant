use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin";
use lib "$FindBin::Bin/lib";
use Test::More;
use TokyoTyrant;

our $Servers;

BEGIN {
	eval {
		require Test::ttserver;
        require Catalyst::Plugin::Authorization::Roles;
		require Test::WWW::Mechanize::Catalyst;
	} or plan skip_all => $@;

    plan test => 3;
    use SetupApp;
	$ENV{'TESTAPP_PLUGINS'} = [ qw(Authentication Session Session::Store::File Session::State::Cookie Authorization::Roles) ];
}

use SetupDB;

use Test::WWW::Mechanize::Catalyst 'TestApp';

my $m = Test::WWW::Mechanize::Catalyst->new();

