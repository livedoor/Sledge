# $Id: 19_host.t,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use Test::More 'no_plan';

use CGI;
use Sledge::Pages::CGI;
use Sledge::Request::CGI;
use IO::Scalar;

$ENV{HTTP_HOST} = 'foo.com';
$ENV{HTTP_VIA} = 'squid';
$ENV{REQUEST_URI} = '/bar.cgi';

@Fake::Pages::ISA = qw(Sledge::Pages::CGI);
my $request = Sledge::Request::CGI->new(CGI->new({}));

is $request->header_in('Via'), 'squid';

my $page = bless { r => $request }, 'Fake::Pages';

tie *STDOUT, 'IO::Scalar', \my $out;
$page->redirect('foo.cgi');
untie *STDOUT;

like $out, qr@Location: http://foo.com/foo.cgi@;

