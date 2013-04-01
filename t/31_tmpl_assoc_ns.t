# $Id: 31_tmpl_assoc_ns.t,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

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

    package Dog;
    my @attr = qw(name speed price);
    use base qw(Class::Accessor);
    __PACKAGE__->mk_accessors(@attr);

    sub param {
	my $self = shift;
	if (@_ == 0) {
	    return @attr;
	}
	elsif (@_ == 1) {
	    my $meth = shift;
	    return $self->$meth();
	}
    }
}

{
    my $page = bless {}, 'Mock::Pages';
    $page->{r} = CGI->new({});
    $page->load_template('ns1');

    my $spot = Dog->new({ name => 'Spot', speed => 0.01 });
    my $snoopy = Dog->new({ name => 'Snoopy', speed => 0.01 });
    $page->tmpl->associate_namespace(foo => $spot);
    $page->tmpl->associate_namespace(bar => $snoopy);

    is $page->tmpl->output, "Spot\n0.01\nSnoopy\n";
}

{
    my $page = bless {}, 'Mock::Pages';
    $page->{r} = CGI->new({});
    $page->load_template('ns1');

    $page->tmpl->associate_namespace(foo => { name => 'Spot', speed => 0.01 });
    $page->tmpl->associate_namespace(bar => { name => 'Snoopy', speed => 0.01 });
    is $page->tmpl->output, "Spot\n0.01\nSnoopy\n";
}

{
    my $page = bless {}, 'Mock::Pages';
    $page->{r} = CGI->new({});
    $page->load_template('ns1');

    my $spot = Dog->new({ name => 'Spot', speed => 0.01 });
    $page->tmpl->associate_namespace(foo => $spot);
    $page->tmpl->associate_namespace(bar => { name => 'Snoopy', speed => 0.01 });
    is $page->tmpl->output, "Spot\n0.01\nSnoopy\n";
}

