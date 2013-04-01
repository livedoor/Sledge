# $Id: 47_exception.t,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use Test::More tests => 7;

package Mock::Pages;
use lib 't/lib';
use base qw(Sledge::TestPages);

Sledge::Exception->do_trace(1);

sub dispatch_foo {
    my $self = shift;
}

use vars qw($TMPL_PATH);
$TMPL_PATH = "t/xx";

package main;

eval { Mock::Pages->new->dispatch('foo') };
isa_ok my $E = $@, 'Sledge::Exception::TemplateNotFound';

is @{$E->stacktrace}, 5, '5 stackframe';
for my $frame (@{$E->stacktrace}) {
    isa_ok $frame, 'Sledge::Exception::StackTrace';
}


