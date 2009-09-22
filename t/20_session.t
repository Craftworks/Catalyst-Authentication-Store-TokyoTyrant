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
		require Catalyst::Plugin::Session;
		require Catalyst::Plugin::Session::State::Cookie;
		require Catalyst::Plugin::Session::Store::File;
		require Test::WWW::Mechanize::Catalyst;
	} or plan skip_all => $@;

	plan tests => 8;

    use SetupApp;
	$ENV{'TESTAPP_PLUGINS'} = [ qw(Authentication Session Session::Store::File Session::State::Cookie) ];
}

use SetupDB;

use Test::WWW::Mechanize::Catalyst 'TestApp';

my $m = Test::WWW::Mechanize::Catalyst->new();

# test login failure
{
	$m->get_ok('http://localhost/login?name=joe&password=a', 'request ok');
	$m->content_is('not logged in', 'check wrong password');
}

# test sucessful login
{
	$m->get_ok('http://localhost/login?name=joe&password=x', 'request ok');
	$m->content_is('joe logged in', 'user logged in');
}

# test logout
{
	$m->get_ok('http://localhost/dologout', 'request ok');
	$m->content_is('logged out', 'log out');
}

# test already logged out
{
	$m->get_ok('http://localhost/dologout', 'request ok');
	$m->content_is('not logged out', 'logged out already');
}
