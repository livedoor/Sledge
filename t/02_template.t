use strict;
use Test::More 'no_plan';

use CGI;
use Sledge::Template;

{
    package Mock::Pages;
    use Sledge::Pages::Compat;
    sub create_config { bless {}, 'Mock::Config' }

    package Mock::Config;
    sub tmpl_path { 't/template' }
}

{
    my $page = bless { r => CGI->new({ foo => 'bar' }) }, 'Mock::Pages';
    my $template = Sledge::Template->new('t/template/test.html', $page);
    $template->param(_foo => 1, _baz => 2);
    is $template->param('_foo'), 1;
    is $template->param('_baz'), 2;

    isa_ok $template, 'Sledge::Template';
    is_deeply \@{$template->{_options}->{associate}}, [ $page->r ], 'associate';

    my $query = CGI->new({ bar => 'baz' });
    ok $template->add_associate($query), 'add_associate';
    is_deeply $template->{_options}->{associate}, [ $page->r, $query ], 'add_associate';
    ok $template->output =~ /bar/, 'output()';

    my $dumb = bless {}, 'Dumm';
    eval { $template->add_associate($dumb) };
    isa_ok $@, 'Sledge::Exception::ParamMethodUnimplemented';
}

{
    my $page = bless { r => Sledge::Request::CGI->new(CGI->new({})) }, 'Mock::Pages';
    $page->load_template('foo');
    isa_ok $page->tmpl, 'Sledge::Template';
    $page->load_template('test');
    isa_ok $page->tmpl, 'Sledge::Template';

    $page->tmpl->param(baz => 'bar');
    is_deeply [ $page->tmpl->param ], [ 'baz' ];

    $page->load_template('test_baz');
    isa_ok $page->tmpl, 'Sledge::Template';
    is_deeply [ $page->tmpl->param ], [ 'baz' ];

    is $page->tmpl->output, "<HTML>\nbar\n</HTML>\n";
}

{
    my $page = bless { r => Sledge::Request::CGI->new(CGI->new({})) }, 'Mock::Pages';
    $page->load_template('test');
    $page->tmpl->add_option(foo => 'bar');
    $page->tmpl->add_option(foo => 'baz');
    $page->tmpl->add_option(bar => 'baz');
    $page->tmpl->add_option(hoge => { aaa => 1 });
    $page->tmpl->add_option(hoge => { bbb => 2 });
    $page->tmpl->set_option(r => 'r');

    no warnings 'redefine';
    local *HTML::Template::new = sub {
	my($self, %args) = @_;
	is_deeply $args{foo}, [ 'bar', 'baz' ];
        is_deeply $args{hoge}, { aaa => 1, bbb => 2 };
	is $args{bar}, 'baz';
	is $args{r}, 'r';
	die 'dummy';
    };
    eval {
	$page->tmpl->output;
	fail 'no ex';
    };
    like $@, qr/dummy/;
}

{
    my $page = bless { r => Sledge::Request::CGI->new(CGI->new({})) }, 'Mock::Pages';
    $page->load_template('xxx');
    eval {
	$page->tmpl->output;
    };
    isa_ok $@, 'Sledge::Exception::TemplateNotFound';
}
