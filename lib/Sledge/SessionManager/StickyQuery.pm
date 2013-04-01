package Sledge::SessionManager::StickyQuery;
# $Id: StickyQuery.pm,v 1.3 2004/02/24 08:51:14 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use base qw(Sledge::SessionManager);

use HTML::StickyQuery 0.10;
use URI;

use vars qw($SessionIdName);
$SessionIdName  = 'sid';

sub import {
    my $class = shift;
    my $pkg   = caller(0);
    no strict 'refs';
    *{"$pkg\::redirect"} = \&redirect_filter;
}

sub redirect_filter {
    my($self, $path, $scheme) = @_;
    my $super = 'Sledge::Pages::Base::redirect';
    if ($path =~ /^http/) {
	# redirect to other server!
	return $self->$super($path, $scheme);
    }
    my $uri = URI->new($path);
    $uri->query_form($uri->query_form, $SessionIdName => $self->session->session_id);
    return $self->$super($uri->as_string, $scheme);
}

sub new {
    my($class, $page) = @_;
    my $self = $class->SUPER::new($page);
    $page->add_filter(\&sid_filter);
    return $self;
}

sub sid_filter {
    my($self, $content) = @_;
    my $sid = $self->session->session_id;

    # XXX we need HTML::StickyAny or something ...
    $content =~ s/(<form\s*.*?>)/$1\n<input type="hidden" name="$SessionIdName" value="$sid">/isg;

    my $sticky = HTML::StickyQuery->new;
    return $sticky->sticky(
	scalarref => \$content,
	param => { $SessionIdName => $sid },
    );
}

sub get_session_id {
    my($self, $page) = @_;
    return $page->r->param($SessionIdName);
}

sub set_session_id { }

1;
