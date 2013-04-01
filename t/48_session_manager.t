# $Id: 48_session_manager.t,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use Test::More;

use lib 't/lib';

package Mock::Pages;
use base qw(Sledge::TestPages);
use Sledge::Session::SQLite;
use Sledge::SessionManager::Cookie;

sub create_session {
    my($self, $sid) = @_;
    return Sledge::Session::SQLite->new($self, $sid);
}

sub create_manager {
    my $self = shift;
    return Sledge::SessionManager::Cookie->new($self);
}

use vars qw($TMPL_PATH $DATASOURCE $COOKIE_NAME);
$TMPL_PATH = "t/template";
$DATASOURCE = [ 'dbi:SQLite:dbname=t/session.db', '', '' ];
$COOKIE_NAME = "test";

sub dispatch_foo { }

package main;

use DBI;

sub create_sessions {
    my $dbh = shift;
    $dbh->do('CREATE TABLE sessions (id VARCHAR(32), a_session TEXT NOT NULL)');
}

sub drop_sessions {
    my $dbh = shift;
    $dbh->do('DROP TABLE sessions');
}

my $dbh = eval { DBI->connect_cached(@{$Mock::Pages::DATASOURCE}, {
    AutoCommit => 1, RaiseError => 1, PrintError => 1,
}); };
plan $dbh ? 'no_plan' : 'skip_all' => 'DBD::SQLite failed';

create_sessions($dbh);


{
    my $p = Mock::Pages->new;
    $p->dispatch('foo');
    like $p->output, qr/Foo/;

    my $cookie = ($p->output =~ /Set-Cookie: (\S+)/)[0];
    like $cookie, qr/test/;

    local $ENV{HTTP_COOKIE} = $cookie;
    drop_sessions($dbh);
    create_sessions($dbh);

    my $p2 = Mock::Pages->new;
    $p2->dispatch('foo');
    my $cookie2 = ($p2->output =~ /Set-Cookie: (\S+)/)[0];

    isnt $cookie, $cookie2, 'differencht session id';
}

END { unlink 't/session.db' if -e 't/session.db' }
