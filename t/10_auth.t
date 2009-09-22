use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin";
use lib "$FindBin::Bin/lib";
use Test::More;
use TokyoTyrant;

our $Servers;

BEGIN {
    eval { require Test::ttserver }
        or plan skip_all => 'Test::ttserver is required for this test';

    use SetupApp;
	$ENV{'TESTAPP_PLUGINS'} = [ qw(Authentication Authorization::Roles) ];
}

use SetupDB;

plan tests => 6;

use Catalyst::Test 'TestApp';

# test login failure
{
    ok(my $res = request('http://localhost/login?name=joe&password=a'), 'request ok');
    is($res->content(), 'not logged in', 'check wrong password');
}

# test sucessful login
{
    ok(my $res = request('http://localhost/login?name=joe&password=x'), 'request ok');
    is($res->content(), 'joe logged in', 'user logged in');
}

# test inactive login
{
    ok(my $res = request('http://localhost/nologin?name=martin&password=z'), 'request ok');
    is($res->content(), 'user martin is inactive', 'user inactive');
}


