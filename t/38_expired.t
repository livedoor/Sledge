# $Id: 38_expired.t,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use Test::More tests => 1;

package Mock::Pages;
use Sledge::Pages::Compat;

sub create_session {
    my $self = shift;
    bless {}, 'Mock::Session';
}

package Mock::Session;
use base qw(Sledge::Session);

sub _delete_me { }
sub _commit { }

package main;
use CGI qw(-no_debug);

my $p = bless {}, 'Mock::Pages';
$p->{r} = Sledge::Request::CGI->new(CGI->new);
$p->{session} = $p->create_session;

$p->session->expire;

ok ! $p->session->is_fresh, 'session is not fresh';



