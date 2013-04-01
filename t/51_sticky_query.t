# $Id: 51_sticky_query.t,v 1.2 2004/02/25 12:08:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use Test::More tests => 4;

use lib 't/lib';

package Mock::Pages;
use base qw(Sledge::TestPages);

use vars qw($TMPL_PATH);
$TMPL_PATH = "t/template";

use Sledge::SessionManager::StickyQuery;

sub create_manager {
    my $self = shift;
    return Sledge::SessionManager::StickyQuery->new($self);
}

sub dispatch_sticky_test {
    my $self = shift;
}

sub dispatch_redirect_test{
    my $self = shift;

    $self->redirect('hoge?foo=bar&baz=baz', 'http');
}

package main;

{
    my $p = Mock::Pages->new;
    $p->dispatch('sticky_test');

    like $p->output, qr/<a href="foo\.cgi\?sid=.*">/;
    like $p->output, qr/<input (?:type="hidden"|name="sid"|value=".*"| )*>/
}

{
    no strict qw(refs);
    no warnings 'redefine';
    local *Sledge::Pages::Base::redirect = sub{
	my ($self, $path, $scheme) = @_;
	like $path, qr/^hoge\?foo=bar&baz=baz&sid=\w+$/;
	is $scheme, 'http';
	$self->finished(1);
    };

    my $p = Mock::Pages->new;
    $p->dispatch('redirect_test');
}


