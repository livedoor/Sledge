# $Id: 16_compat.t,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $

use strict;
use Test::More 'no_plan';

package Test::Pages;
use Sledge::Pages::Compat;

package main;
{
    my $page = bless {}, 'Test::Pages';
    isa_ok $page, 'Sledge::Pages::CGI';
}
