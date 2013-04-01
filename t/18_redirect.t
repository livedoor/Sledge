# $Id: 18_redirect.t,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use Test::More 'no_plan';

use IO::Scalar;
use Sledge::Pages::CGI;
use Sledge::Request::CGI;

# CGI env var
$ENV{QUERY_STRING} = '';
$ENV{REQUEST_URI} = '/foo/bar.cgi';
$ENV{HTTP_HOST} = 'hostname';

{
    my $page = bless {
	r => Sledge::Request::CGI->new(CGI->new({})),
    }, 'Sledge::Pages::CGI';

    tie *STDOUT, 'IO::Scalar', \my $out;
    $page->redirect('foo.cgi');
    untie *STDOUT;

    like $out, qr@Location: http://hostname/foo/foo\.cgi@;
}

{
    my $page = bless {
	r => Sledge::Request::CGI->new(CGI->new({})),
    }, 'Sledge::Pages::CGI';

    tie *STDOUT, 'IO::Scalar', \my $out;
    $page->redirect('foo.cgi', 'http');
    untie *STDOUT;

    like $out, qr@Location: http://hostname/foo/foo\.cgi@;
}

{
    local $ENV{HTTPS} = 1;
    my $page = bless {
	r => Sledge::Request::CGI->new(CGI->new({})),
    }, 'Sledge::Pages::CGI';

    tie *STDOUT, 'IO::Scalar', \my $out;
    $page->redirect('foo.cgi', 'http');
    untie *STDOUT;

    like $out, qr@Location: http://hostname/foo/foo\.cgi@;
}


{
    local $ENV{HTTPS} = 1;
    my $page = bless {
	r => Sledge::Request::CGI->new(CGI->new({})),
    }, 'Sledge::Pages::CGI';

    tie *STDOUT, 'IO::Scalar', \my $out;
    $page->redirect('foo.cgi');
    untie *STDOUT;

    like $out, qr@Location: https://hostname/foo/foo\.cgi@;
}

{
    my $page = bless {
	r => Sledge::Request::CGI->new(CGI->new({})),
    }, 'Sledge::Pages::CGI';

    tie *STDOUT, 'IO::Scalar', \my $out;
    $page->redirect('http://localhost/foo.cgi');
    untie *STDOUT;

    like $out, qr@Location: http://localhost/foo\.cgi@;
}


