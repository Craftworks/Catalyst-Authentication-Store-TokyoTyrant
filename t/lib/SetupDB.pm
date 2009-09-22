use Test::More;
use Test::ttserver;
use TokyoTyrant;

our @ttservers;
for (@$Servers) {
    my $ttserver = Test::ttserver->new(
        $_->{'port'}.'.tct',
        host => $_->{'host'},
        port => $_->{'port'},
    );
    unless ( $ttserver ) {
        plan 'skip_all' => $Test::ttserver::errstr;
        last;
    }
    push @ttservers, $ttserver;

    my $rdb = TokyoTyrant::RDBTBL->new;
    $rdb->open($_->{'host'}, $_->{'port'}) or die $rdb->errmsg($rdb->ecode);
    my $uid;
    $uid = $rdb->genuid;
    $rdb->put($uid, { 'id' => $uid, 'name' => 'joe', 'password' => 'x', 'role' => 'admin,user' });
    $uid = $rdb->genuid;
    $rdb->put($uid, { 'id' => $uid, 'name' => 'bob', 'password' => 'z', 'role' => 'user' });
}

1;
