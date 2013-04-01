# $Id: 21_request_uri.t,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use Test::More 'no_plan';

use CGI;
use Sledge::Request::CGI;

my $r = Sledge::Request::CGI->new(CGI->new({}));

{
    local $ENV{REQUEST_URI} = '/foo/bar.cgi';
    is $r->uri, '/foo/bar.cgi', $r->uri;
}

{
    local $ENV{REQUEST_URI} = '/foo/bar.cgi?foo=bar';
    is $r->uri, '/foo/bar.cgi', $r->uri;
}

