# $Id: 43_tt_import.t,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#
use strict;
use Test::More;

BEGIN {
    eval { require Template; };
    plan $@ ? (skip_all => 'no Template-Toolkit') : ('no_plan');
}


{
    package Mock::Pages;
    use Sledge::Template::TT;
    use Sledge::Pages::Compat;

    sub create_config { bless {}, 'Mock::Config' }

    package Mock::Config;
    sub tmpl_path { 't/template' }

    package Dog;
    use base qw(Class::Accessor);

    sub bark { 'Bowwow' }
}

{
    my $dog = Dog->new({ name => 'Spot' });

    my $page = bless {}, 'Mock::Pages';
    $page->load_template('foo');
    $page->tmpl->param(foo => "foo");
    $page->tmpl->param(dog => $dog);

    my $out = $page->tmpl->output;
    like $out, qr/^Foo: foo/m, $out;
    like $out, qr/^Dog bark: Bowwow/m;
    like $out, qr/^Dog name: Spot/m;

    eval { $page->tmpl->add_associate(); };
    isa_ok $@, 'Sledge::Exception::UnimplementedMethod';

    eval { $page->tmpl->associate_namespace(); };
    isa_ok $@, 'Sledge::Exception::UnimplementedMethod';
}

