# $Id: 50_content_filter.t,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use Test::More tests => 7;

use lib 't/lib';

package Mock::Pages;
use base qw(Sledge::TestPages);

use vars qw($TMPL_PATH);
$TMPL_PATH = "t/template";

sub dispatch_foo {
    my $self = shift;
    $self->tmpl->param(foo => 'FOO');
    $self->tmpl->param(dog => { bark => 'WOO', name => 'snoop' });
}

package main;

{
    my $p = Mock::Pages->new;
    $p->add_filter(sub { return 'xxx' });
    $p->dispatch('foo');

    like $p->output, qr/xxx/;
}

{
    my $p = Mock::Pages->new;
    $p->add_filter(sub { my($self, $content) = @_; return lc $content });
    $p->dispatch('foo');

    like $p->output, qr/foo: foo/, 'lc filter';
    like $p->output, qr/dog bark: woo/;
    like $p->output, qr/dog name: snoop/;
}

{
    my $p = Mock::Pages->new;
    $p->add_filter(sub { my($self, $content) = @_; return lc $content });
    $p->add_filter(sub { my($self, $content) = @_; return uc $content });
    $p->dispatch('foo');

    like $p->output, qr/FOO: FOO/, 'lc filter';
    like $p->output, qr/DOG BARK: WOO/;
    like $p->output, qr/DOG NAME: SNOOP/;
}



1;
