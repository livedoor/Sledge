# $Id: 52_rewrite_query.t,v 1.2 2004/02/25 12:08:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co.,Ltd.
#

use strict;
use Test::More tests => 3;

use lib 't/lib';

package Mock::Pages;
use base qw(Sledge::TestPages);

use vars qw($TMPL_PATH);
$TMPL_PATH = "t/template";

use Sledge::SessionManager::Rewrite;

sub create_manager {
    my $self = shift;
    return Sledge::SessionManager::Rewrite->new($self);
}


sub dispatch_index {
    my $self = shift;
}

sub redirect { }

package main;

{
    $ENV{REQUEST_URI}  = "/index";
    $ENV{QUERY_STRING} = "id=1";

    # no session id: should redirect
    no warnings 'redefine';
    local *Mock::Pages::redirect = sub {
	my($self, $uri) = @_;
	my $sid = ($uri =~ qr!/sid=(.*?)/!)[0];
	is length($sid), 32, "sid = $sid";

	like $uri, qr/\?id=1/, "uri has id=1";
	die "Dummy";
    };
    my $p = Mock::Pages->new;
    eval {
	$p->dispatch('index');
    };
    like $@, qr/Dummy/, "dummy exception";
}

