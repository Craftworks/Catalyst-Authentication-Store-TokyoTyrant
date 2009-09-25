package Catalyst::Authentication::Store::TokyoTyrant::User;

use strict;
use warnings;
use Encode;
use base 'Catalyst::Authentication::User';
use base 'Class::Accessor::Fast';

__PACKAGE__->mk_accessors(qw/config _user _roles/);

sub new {
    my ( $class, $config, $user ) = @_;

    return unless $user;

    if ( $config->{'decode_utf8'} ) {
        for ( values %$user ) {
            $_ = decode_utf8($_);
        }
    }

    my $self = {
        'config' => $config,
        '_user'  => $user,
    };

    return bless $self, $class;
}

sub id {
    my $self = shift;
    my $user_key = $self->config->{'user_key'};
    return $self->_user->{$user_key};
}

sub supported_features {
    return +{
        'session' => 1,
        'roles'   => 1,
    };
}

sub get {
    my ( $self, $fieldname ) = @_;
    return unless exists $self->_user->{$fieldname};
    return $self->_user->{$fieldname};
}

sub get_object {
    shift->_user;
}

sub obj {
    shift->_user;
}

sub roles {
    my $self = shift;

    if ( ref $self->_roles eq 'ARRAY' ) {
        return @${ $self->_roles };
    }

    my $role_key = $self->config->{'role_key'};

    unless ( defined $role_key ) {
        Catalyst::Exception->throw(q/user->roles accessed, but no role configuration found/);
    }

    my @roles;
    if ( my $role_data = $self->get($role_key) ) {
        @roles = split /[\s,\|]+/, $role_data;
    }
    $self->_roles(\@roles);

    return @{ $self->_roles };
}

1;
