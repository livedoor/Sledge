package Sledge::SessionManager::Cookie;
# $Id: Cookie.pm,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use base qw(Sledge::SessionManager);
use CGI::Cookie;

sub get_session_id {
    my($self, $page) = @_;
    my $config = $page->create_config;
    my %jar    = CGI::Cookie->fetch;
    my $cookie = $jar{$config->cookie_name};
    return $cookie ? $cookie->value : undef;
}

sub set_session_id {
    my($self, $page, $sid) = @_;
    my $config = $page->create_config;
    my %options = (
	-name   => $config->cookie_name,
        -value  => $sid,
        -path   => $config->cookie_path,
    );
    $options{'-domain'} = $config->cookie_domain if $config->cookie_domain;

    my $cookie = CGI::Cookie->new(%options);
    $page->r->header_out('Set-Cookie' => $cookie->as_string);
}

1;
