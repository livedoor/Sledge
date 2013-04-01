use strict;
use Test::More tests => 11;

use CGI;
use Sledge::Request::CGI;

{
    package Catch;
    sub TIEHANDLE { bless {}, shift }
    sub PRINT {
	my $self = shift;
	$self->{caught} .= join '', @_;
    }
}

{
    my $r = Sledge::Request::CGI->new(CGI->new({ foo => 'bar' }));
    ok $r->isa('Sledge::Request::CGI'), 'new';
    ok $r->can('param'), 'can param';
    ok eq_array([ $r->param ], [ 'foo' ]), 'param returns list';
    is $r->param('foo'), 'bar', 'param foo';

    $r->header_out(Foo => 'bar');
    $r->content_type('text/html');

    my $out = tie *STDOUT, 'Catch';
    $r->send_http_header;
    my $caught = $out->{caught};
    undef $out;
    untie *STDOUT;

    like $caught, qr/Foo: bar/;
    like $caught, qr[Content-Type: text/html];
}

{
    my $r = Sledge::Request::CGI->new(CGI->new({}));
    ok eq_array([ $r->param ], [ ]), 'empty';

    $r->param(foo => 'bar');
    is $r->param('foo'), 'bar', 'param() works';

    $r->param(bar => qw(a b c));
    ok eq_array([ $r->param('bar') ], [ qw(a b c) ]), 'param';

    $r->param(baz => [qw(a b c)]);
    ok eq_array([ $r->param('baz') ], [ qw(a b c) ]), 'param';
    ok eq_array([ sort $r->param ], [ sort qw(foo bar baz) ]), 'param';
}


