# $Id: 53_sessionmanager_any.t,v 1.2 2004/02/24 13:29:50 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.jp>
# EDGE, Co.,Ltd.
#

use strict;
use Test::More tests => 5;

use lib "t/lib";

package Mock::Pages;
use base qw(Sledge::TestPages);

use Sledge::SessionManager::Any;

sub create_manager {
    my $self = shift;
    Sledge::SessionManager::Any->new($self);
}

sub dispatch_sticky_test { }

sub dispatch_bar {
    my $self = shift;
    die $self->session->session_id;
}

sub used_only_once { }

$Mock::Pages::TMPL_PATH = "t/template";
$Mock::Pages::COOKIE_NAME = "sid";

used_only_once($Mock::Pages::TMPL_PATH, $Mock::Pages::COOKIE_NAME);

package main;

do_test(1);
do_test(0);

sub do_test {
    my($use_cookie) = @_;

    my $p = Mock::Pages->new;
    $p->dispatch("sticky_test");

    # get the SID from cookie
    my($sid) = $p->output =~ /sid=(\w+)/;

    # does it rewrite HTML?
    like $p->output, qr/foo\.cgi\?sid=$sid/, "HTML contains $sid in links";

    if ($use_cookie) {
	$ENV{HTTP_COOKIE} = "sid=$sid";

    } else {
	$ENV{REQUEST_METHOD} = "GET";
	$ENV{QUERY_STRING} = "sid=$sid";
    }

    # check Session ID
    my $p2 = Mock::Pages->new;
    eval { $p2->dispatch("bar") };
    like $@, qr/$sid/, "Session ID: $sid";

    my $p3 = Mock::Pages->new;
    $p3->dispatch("sticky_test");

    if ($use_cookie) {
	unlike $p3->output, qr/foo\.cgi\?sid=$sid/, "no StickyQuery with Cookie enabled";
    }

    delete $ENV{HTTP_COOKIE};
    delete $ENV{QUERY_STRING};
}
