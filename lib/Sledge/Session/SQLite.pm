package Sledge::Session::SQLite;
# $Id: SQLite.pm,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use base qw(Sledge::Session::DBI);

use MIME::Base64;
use Storable;
use Sledge::Exceptions;

sub connect_attr {
    return {
	PrintError => 1, RaiseError => 1, AutoCommit => 1,
    };
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

sub _transaction { 0 }

sub _do_cleanup { Sledge::Exception::UnimplementedMethod->throw }

1;
