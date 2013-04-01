#!/usr/local/bin/perl
# $Id: session-bench.pl,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;

use Benchmark;
use DBI;
use Apache::Session::MySQL;
use Sledge::Session::MySQL;

# --------------------------------------------------

my $st = setup_table() or exit;

$SIG{INT} = sub { exit };
END {
    teardown_table() if $st;
}

sub setup_table {
    my $dbh = DBI->connect('dbi:mysql:test', 'root', '', { PrintError => 0 })
	or return;
    $dbh->do(<<SQL);
CREATE TABLE sessions (
    id CHAR(32) NOT NULL PRIMARY KEY,
    a_session TEXT NOT NULL
)
SQL
    ;
}

sub teardown_table {
    my $dbh = DBI->connect('dbi:mysql:test', 'root', '')
	or return;
    $dbh->do('DROP TABLE sessions');
    $dbh->disconnect;
}

# --------------------------------------------------

package Mock::Pages;
sub create_config {
    bless {}, 'Mock::Config';
}

package Mock::Config;
sub datasource {
    return 'dbi:mysql:test', 'root', '';
}

package main;
timethese 500, {
    sledge_session => \&sledge_session,
    apache_session => \&apache_session,
};

my $i;

sub sledge_session {
    my $page = bless {}, 'Mock::Pages';

    my $session = Sledge::Session::MySQL->new($page);
    $session->param(foo => 'bar');
    $session->param(bar => [ 'bar', 'baz' ]);
    $session->param(baz => bless {}, 'Bar');
    $session->remove('foo');
    $session->expire unless $i++ % 10;
}

sub apache_session {
    my $page = bless {}, 'Mock::Pages';

    my @dsn = $page->create_config->datasource;
    tie my %session, 'Apache::Session::MySQL', 0, {
	DataSource => $dsn[0],
	UserName => $dsn[1],
	Password => $dsn[2],
	LockDataSource => $dsn[0],
	LockUserName => $dsn[1],
	LockPassword => $dsn[2],
    };

    $session{foo} = 'bar';
    $session{bar} = [ 'bar', 'baz' ];
    $session{baz} = bless {}, 'Bar';
    delete $session{'foo'};
    tied(%session)->delete unless $i++ % 10;
}

