package Catalyst::Authentication::Store::TokyoTyrant;

use warnings;
use strict;
use TokyoTyrant;
use Catalyst::Authentication::Store::TokyoTyrant::User;

our $AUTHORITY = 'cpan:CRAFTWORK';
our $VERSION = '0.001';
$VERSION = eval $VERSION;

sub new {
    my ( $class, $config, $app, $realm ) = @_;
    my $self = bless $config, $class;
    return $self;
}

sub _rdb {
    my ( $self, $c ) = @_;

    my $index = int rand @{ $self->{'servers'} };
    my $socket = $self->{'servers'}[$index];

    my $connections = $self->{'_connections'};
    my $rdb = $connections->{$socket};

    # first time
    unless ( $rdb ) {
        $c->log->debug(q/The storage is not connected yet.  Trying to connect./);
        $rdb = $connections->{$socket} = $self->_connect($socket);
    }
    # auto reconnect
    unless ( $rdb->stat ) {
        $c->log->debug(q/The connection is not available.  Trying to reconnect./);
        $rdb = $connections->{$socket} = $self->_connect($socket, $rdb);
    }

    return $rdb;
}

sub _connect {
    my ( $self, $socket, $rdb ) = @_;
    $rdb ||= TokyoTyrant::RDBTBL->new;
    unless ( $rdb->open(@$socket{qw/host port/}) ) {
        Catalyst::Exception->throw(sprintf '%s, %s:%s',
            $rdb->errmsg($rdb->ecode), @$socket{qw/host port/});
    }
    return $rdb;
}

sub find_user {
    my ($self, $authinfo, $c) = @_;

    my $rdb = $self->_rdb($c);

    my $qry = TokyoTyrant::RDBQRY->new( $rdb );
    while (my ($column, $value) = each %$authinfo) {
        my $cond = $value =~ !/^\d+$/o ? 'QCNUMEQ' : 'QCSTREQ';
        $qry->addcond( $column, $qry->$cond, $value );
    }
    $qry->setlimit(1);
    my $keys = $qry->search;
    my $user = $rdb->get(@$keys);
    my $user_key = $self->{'user_key'};

    unless ( exists $user->{$user_key} && length $user->{$user_key} ) {
        return;
    }

    Catalyst::Authentication::Store::TokyoTyrant::User->new($self, $user);
}

sub for_session {
    my ( $self, $c, $user ) = @_;
    return $user->id;
}

sub from_session {
    my ( $self, $c, $frozen ) = @_;

    my $rdb = $self->_rdb($c);

    my $qry = TokyoTyrant::RDBQRY->new( $rdb );
    my $cond = $frozen =~ /^\d+$/o ? 'QCNUMEQ' : 'QCSTREQ';
    $qry->addcond( $self->{'user_key'}, $qry->$cond, $frozen );
    $qry->setlimit(1);
    my $keys = $qry->search;
    my $user = $rdb->get(@$keys);
    my $user_key = $self->{'user_key'};

    unless ( exists $user->{$user_key} && length $user->{$user_key} ) {
        return;
    }

    Catalyst::Authentication::Store::TokyoTyrant::User->new($self, $user);
}

sub user_supports {
    return;
}

1;

__END__

=head1 NAME

Catalyst::Authentication::Store::TokyoTyrant - Storage class for Catalyst
Authentication using TokyoTyrant

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Catalyst::Authentication::Store::TokyoTyrant;

    my $foo = Catalyst::Authentication::Store::TokyoTyrant->new;
    ...

=head1 DESCRIPTION

The fantastic new Catalyst::Authentication::Store::TokyoTyrant!

=head1 EXPORTS

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 METHODS

=head2 new

=head2 find_user

=head2 for_session

=head2 from_session

=head2 user_supports

=head1 AUTHOR

Craftworks, C<< <craftwork at cpan org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-catalyst-authentication-store-tokyotyrant@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically be
notified of progress on your bug as I make changes.

=head1 COPYRIGHT

Copyright (C) 2009 Craftworks, All Rights Reserved.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
