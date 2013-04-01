package Sledge::SessionManager::Rewrite;
# $Id: Rewrite.pm,v 1.3 2004/02/24 08:51:14 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use base qw(Sledge::SessionManager);

use vars qw($SessionIdName);
$SessionIdName  = 'sid';

# RewriteRule ^/sid=([^/]+)/(.*) /$2 [E=SESSIONID:$1]
sub get_session_id {
    my($self, $page) = @_;
    return $ENV{SESSIONID};
}

sub set_session_id {
    my($self, $page, $sid) = @_;
    my $uri = $page->r->uri;
    if ($uri =~ s@/$SessionIdName=[^/]+/@/$SessionIdName=$sid/@) {
	$uri .= "?". scalar($page->r->args) if length($page->r->args);
        $page->redirect($uri);
    } else {
        $page->redirect($self->add_sid($page, $sid));
    }
}

sub add_sid {
    my($self, $page, $sid) = @_;
    my $args = $page->r->args;
    return sprintf '/%s=%s%s%s', $SessionIdName, $sid, $page->r->uri,
	length($args) ? "?$args" : '';
}

1;
