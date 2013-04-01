package Sledge::Session::Pg;
# $Id: Pg.pm,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

# I recommend you not to use PostgreSQL for Session management. See
#   http://www6.jp.postgresql.org/users-lounge/docs/7.2/postgres/applevel-consistency.html
#   http://www.postgresql.jp/document/pg721doc/user/applevel-consistency.html
# for details.

use strict;
use base qw(Sledge::Session::DBI);

use MIME::Base64;
use Storable;
use Sledge::Exceptions;

use vars qw($TimeStampColumn);
$TimeStampColumn = 'last_access';

sub connect_attr {
    return {
	PrintError => 1, RaiseError => 1, AutoCommit => 0,
    };
}

sub _select_me {
    my $self = shift;
    $self->SUPER::_select_me('FOR UPDATE');
}

sub _do_lock { }

sub _serialize {
    my($self, $data) = @_;
    return encode_base64(Storable::freeze($data));
}

sub _deserialize {
    my($self, $data) = @_;
    return Storable::thaw(decode_base64($data));
}

sub _transaction { 1 }

sub _do_cleanup { 
    my($self, $dbh, $min) = @_;
    my $sth = $dbh->prepare(<<SQL);
DELETE FROM sessions
WHERE $TimeStampColumn + ? < CURRENT_TIMESTAMP
SQL
    ;
    $sth->execute("$min minutes");
    $sth->finish;
    $self->_commit;
}

1;
