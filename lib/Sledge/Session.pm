package Sledge::Session;
# $Id: Session.pm,v 1.4 2005/07/12 11:12:35 yoshiki Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use Digest::SHA1 qw(sha1_hex);
use Storable;
use Time::HiRes qw(gettimeofday);

use Sledge::Exceptions;

use vars qw($SessionIdLength);
$SessionIdLength = 32;

sub sid_length { $SessionIdLength }

sub new {
    my($class, $page, $sid) = @_;
    my $self = bless {
	_sid  => $sid,
	_dbh  => undef,
	_data => {},
	_changed => 0,
	_new  => 0,
	_lock => undef,
    }, $class;
    $self->_load_session($page);
    return $self;
}

sub _load_session {
    my($self, $page) = @_;

    # no sid; generate it
    unless ($self->{_sid}) {
	$self->{_sid} = $self->_gen_session_id($page);
	$self->{_new} = 1;
    }

    # database connection
    $self->{_dbh} = $self->_connect_database($page);

    # SELECT FROM sessions
    $self->_do_lock;
    $self->_select_me unless $self->{_new};
}

sub _gen_session_id {
    my $self = shift;
    my $unique = $ENV{UNIQUE_ID} || [] . rand();
    return substr(sha1_hex(gettimeofday . $unique), 0, $self->sid_length);
}

sub _deserialize {
    my($self, $data) = @_;
    return Storable::thaw($data);
}

sub _serialize {
    my($self, $data) = @_;
    return Storable::nfreeze($data);
}

sub _transaction { }

sub DESTROY {
    my $self = shift;
    if ($self->{_dbh}) {
	$self->_insert_me if $self->{_new};
	$self->_update_me if !$self->{_new} && $self->{_changed};
	$self->{_lock}->($self) if defined $self->{_lock};
	$self->_commit;
    }
}

# developer APIs:
sub _connect_database    { Sledge::Exception::AbstractMethod->throw }
sub _commit              { Sledge::Exception::AbstractMethod->throw }
sub _do_lock             { Sledge::Exception::AbstractMethod->throw }
sub _lockid              { Sledge::Exception::AbstractMethod->throw }
sub _select_me           { Sledge::Exception::AbstractMethod->throw }
sub _insert_me           { Sledge::Exception::AbstractMethod->throw }
sub _update_me           { Sledge::Exception::AbstractMethod->throw }
sub _delete_me           { Sledge::Exception::AbstractMethod->throw }
sub _do_cleanup          { Sledge::Exception::AbstractMethod->throw }

# public APIs:
# param, remove, expire, session_id
sub param {
    my $self = shift;
    if (@_ == 0) {
	return keys %{$self->{_data}};
    }
    elsif (@_ == 1) {
	return $self->{_data}->{$_[0]};
    }
    else {
	$self->{_changed}++;
	$self->{_data}->{$_[0]} = $_[1];
    }
}

sub remove {
    my($self, $key) = @_;
    $self->{_changed}++;
    delete $self->{_data}->{$key};
}

sub expire {
    my $self = shift;
    $self->_delete_me;
    $self->_commit;

    # XXX tricky bit to unlock
    delete $self->{$_} for qw(_new _changed);
    $self->DESTROY;

    # rebless to null class
    bless $self, 'Sledge::Session::Expired';
}

sub session_id {
    my $self = shift;
    return $self->{_sid};
}

sub is_fresh {
    my $self = shift;
    return $self->{_new};
}

sub cleanup {
    my($class, $page, $min) = @_;
    unless ($min =~ /^\d+$/) {
	Sledge::Exception::ArgumentTypeError->throw("timeout minute should be digit: $min");
    }
    my $dbh = $class->_connect_database($page);
    $class->_do_cleanup($dbh, $min);
}

package Sledge::Session::Expired;

sub is_fresh { 0 }

sub AUTOLOAD { }

1;
