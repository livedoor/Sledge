# $Id: 44_tt_hook.t,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use Test::More tests => 5;

use lib 't/lib';

package Mock::Pages;
use base qw(Sledge::TestPages);
use Sledge::Template::TT;

sub dispatch_name {
    my $self = shift;
    $self->session->param(var => 'value');
    ::isa_ok $self->tmpl->param('session'), 'Sledge::Session';
    ::isa_ok $self->tmpl->param('r'), 'Sledge::Request::CGI';
    ::isa_ok $self->tmpl->param('config'), 'Sledge::TestConfig';
}

package main;

$ENV{HTTP_HOST}      = "localhost";
$ENV{REQUEST_URI}    = "http://localhost/name.cgi";
$ENV{REQUEST_METHOD} = 'GET';
$ENV{QUERY_STRING}   = 'name=miyagawa';

my $d = $Mock::Pages::TMPL_PATH;
$Mock::Pages::TMPL_PATH = "t/template";
my $page = Mock::Pages->new;
$page->dispatch('name');

my $out = $page->output;
like $out, qr/name is miyagawa/;
like $out, qr/session var is value/;






