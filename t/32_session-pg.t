# $Id: 32_session-pg.t,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use Test::More;

use DBI;
use IO::Scalar;
use Sledge::Session::Pg;

# --------------------------------------------------

my $dbh;
my $st = setup_table();
plan $st ? (tests => 15) : (skip_all => 'no pg connection');


$SIG{INT} = sub { exit };
END {
    teardown_table() if $dbh;
}

sub setup_table {
    eval { require DBD::Pg; 1; } or return;
    my $session = bless {}, 'Sledge::Session::Pg';
    my $page    = bless {}, 'Mock::Pages';
    $dbh     = eval { $session->_connect_database($page) } or return;

    # Shut up warning
    local *OLDERR;
    open OLDERR, ">&STDERR"; open STDERR, ">/dev/null";

    $dbh->do(<<SQL);
CREATE TABLE sessions (
    id CHAR(32) NOT NULL PRIMARY KEY,
    a_session TEXT NOT NULL
)
SQL
    ;
    $dbh->commit;

    # restore
    close STDERR; open STDERR, ">&OLDERR";
    return 1;
}

sub teardown_table {
    $dbh->do('DROP TABLE sessions');
    $dbh->commit;
    $dbh->disconnect;
}

# --------------------------------------------------

package Mock::Pages;
sub create_config {
    bless {}, 'Mock::Config';
}

package Mock::Config;
sub datasource {
    return 'dbi:Pg:dbname=template1', 'pg', '';
}

package main;
my $page = bless {}, 'Mock::Pages';

my $sid;
{
    ok(my $session = Sledge::Session::Pg->new($page),
       'session create');
    $sid = $session->session_id;
    like $sid, qr/^[0-9a-f]{32}$/, "sid char(32) $sid";

    ok $session->is_fresh, 'is_fresh';
    ok $session->param(foo => 'bar'), 'can param';
    ok $session->param(bar => [ 'bar', 'baz' ]), 'can param reference';
    is $session->param('foo'), 'bar', 'param() returns';
    is_deeply $session->param('bar'), [ 'bar', 'baz' ], 'ref';
    is_deeply [ sort $session->param ], [ qw(bar foo) ], 'param()';

    ok $session->remove('foo'), 'remove';
    is $session->param('foo'), undef, 'remove succeed';
}

{
    ok(my $session = Sledge::Session::Pg->new($page, $sid),
       'restore session');
    ok ! $session->is_fresh, 'is not fresh';
    is $session->session_id, $sid, "$sid same";
    is_deeply $session->param('bar'), [ 'bar', 'baz' ], 'ref';
    $session->expire;
}

{
    eval {
	my $session = Sledge::Session::Pg->new($page, $sid);
	fail "no exception";
    };
    isa_ok $@, 'Sledge::Exception::SessionIdNotFound';
}
