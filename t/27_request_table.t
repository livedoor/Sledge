# $Id: 27_request_table.t,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use Test::More 'no_plan';

use Sledge::Request::Table;

{
    my $t = Sledge::Request::Table->new({ foo => 1, bar => 2 });
    isa_ok $t, 'Sledge::Request::Table';

    is $t->get('foo'), 1;
    is $t->get('bar'), 2;

    $t->set(foo => 2);
    is $t->get('foo'), 2;

    $t->unset('foo');
    is $t->get('foo'), undef;

    $t->clear;
    is_deeply {%$t}, {};

    $t->add(foo => 1);
    $t->add(foo => 2);
    is_deeply [ $t->get('foo') ], [ 1, 2 ];
}
