# $Id: 45_tt_include.t,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use Test::More tests => 2;

use lib 't/lib';

package Mock::Pages;
use base qw(Sledge::TestPages);
use Sledge::Template::TT;

sub dispatch_include1 {}

package main;

$ENV{HTTP_HOST}      = "localhost";
$ENV{REQUEST_URI}    = "http://localhost/include1.cgi";
$ENV{REQUEST_METHOD} = 'GET';

my $d = $Mock::Pages::TMPL_PATH;
$Mock::Pages::TMPL_PATH =  "t/template";
my $page = Mock::Pages->new;
$page->dispatch('include1');

my $out = $page->output;
like $out, qr/include1/, $out;
like $out, qr/include2/, $out;
