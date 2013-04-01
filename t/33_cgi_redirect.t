# $Id: 33_cgi_redirect.t,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use Test::More tests => 2;

use CGI;
use IO::Scalar;
use Sledge::Request::CGI;

package Mock::Pages;
use base qw(Sledge::Pages::CGI);

package main;
my $p = bless {}, 'Mock::Pages';
$p->{r} = Sledge::Request::CGI->new(CGI->new({}));

# setup env
$ENV{HTTP_HOST} = 'localhost';
$ENV{REQUEST_URI} = '/foo';

tie *STDOUT, 'IO::Scalar', \my $out;
$p->r->header_out(Foo => 'bar');
$p->redirect('foo.html');
untie *STDOUT;

like $out, qr/Foo: bar/, $out;
like $out, qr@Location: http://localhost/foo\.html@;





