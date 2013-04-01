# $Id: 37_send_http_header.t,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use Test::More tests => 1;

use CGI qw(-no_debug);

package Mock::Pages;
use Sledge::Pages::Compat;

sub send_http_header {
    die 'send_http override';
}

package main;

$ENV{HTTP_HOST} = 'localhost';
$ENV{REQUEST_URI} = '/foo';

my $p = bless {}, 'Mock::Pages';
$p->{r} = Sledge::Request::CGI->new(CGI->new);

eval {
    $p->redirect('bar');
    fail 'no exception';
};

like $@, qr/send_http override/;

