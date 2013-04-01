package Sledge::Session::DBI;
# $Id: DBI.pm,v 1.2 2003/02/20 05:38:30 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use base qw(Sledge::Session);

use DBI;
use Sledge::Exceptions;

sub connect_attr { Sledge::Exception::AbstractMethod->throw }

sub _connect_database {
    my($self, $page) = @_;
    my $config = $page->create_config;
    my $connect = $ENV{MOD_PERL} ? 'connect' : 'connect_cached';
    my $dbh = DBI->$connect($config->datasource, $self->connect_attr)
	or Sledge::Exception::DBConnectionError->throw($DBI::errstr);
    return $dbh;
}

sub _prepare {
    my($self, $sql) = @_;
    return $self->{_dbh}->prepare_cached($sql);
}

sub _commit {
    my $self = shift;
    if ($self->{_dbh} && $self->_transaction) {
	$self->{_dbh}->commit;
    }
}

sub _select_me {
    my($self, $opt) = @_;
    my $sql = 'SELECT a_session FROM sessions WHERE id=?';
       $sql .= " $opt" if $opt;
    my $sth = $self->_prepare($sql);
    $sth->execute($self->{_sid});
    my $data = $sth->fetchrow_arrayref;
    $sth->finish;
    unless ($data) {
	Sledge::Exception::SessionIdNotFound->throw(
	    'no such session_id in database.',
	);
    }
    $self->{_data} = $self->_deserialize($data->[0]);
}

sub _insert_me {
    my $self = shift;
    my $sth = $self->_prepare('INSERT INTO sessions (id, a_session) VALUES (?, ?)');
    $sth->execute($self->{_sid}, $self->_serialize($self->{_data}));
}

sub _update_me {
    my $self = shift;
    my $sth = $self->_prepare('UPDATE sessions SET a_session=? WHERE id=?');
    $sth->execute($self->_serialize($self->{_data}), $self->{_sid});
}

sub _delete_me {
    my $self = shift;
    my $sth = $self->_prepare('DELETE FROM sessions WHERE id=?');
    $sth->execute($self->{_sid});
}

1;
