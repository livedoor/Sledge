# $Id: 49_content-length.t,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use Test::More 'no_plan';

use lib 't/lib';

package Mock::Pages;
use base qw(Sledge::TestPages);
use Sledge::Template::TT;

sub dispatch_foo { }

package main;

$ENV{HTTP_HOST}      = "localhost";
$ENV{REQUEST_URI}    = "http://localhost/foo";
$ENV{REQUEST_METHOD} = 'GET';

my $d = $Mock::Pages::TMPL_PATH;
$Mock::Pages::TMPL_PATH =  "t/template";
my $page = Mock::Pages->new;
$page->dispatch('foo');

my $out = $page->output;
like $out, qr/Content-Length: \d+/;
