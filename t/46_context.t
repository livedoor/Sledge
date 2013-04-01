# $Id: 46_context.t,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use Test::More tests => 5;

use Sledge::Registrar;

eval {
    my $p = Sledge::Registrar->context;
};
isa_ok $@, 'Sledge::Exception::NoContextRunning';

package Mock::Pages;
use lib 't/lib';
use base qw(Sledge::TestPages);

sub dispatch_foo {
    WantPages->action(shift);
}

sub say_ok {
    ::pass "come here";
}

local $Mock::Pages::TMPL_PATH;
$Mock::Pages::TMPL_PATH = "t";


package WantPages;

sub action {
    my($class, $page) = @_;
    my $p = Sledge::Registrar->context;
    ::isa_ok $p, 'Mock::Pages';
    ::is "$p", "$page", "same object";
    $p->say_ok;
}

package main;

my $page = Mock::Pages->new;
eval {
    $page->dispatch('foo');
};
isa_ok $@, 'Sledge::Exception::TemplateNotFound';


