# $Id: 40_output_hook.t,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use Test::More tests => 4;

package Mock::Pages;
use Sledge::Pages::Compat;

__PACKAGE__->register_hook(
    AFTER_OUTPUT => sub {
	my $self = shift;
	$self->{foo} = "bar";
    },
);

sub charset { bless {}, 'Mock::Charset' }

sub tmpl { bless {}, 'Mock::Template'  }

package Mock::Charset;
sub content_type { 'euc-jp' }
sub output_filter { $_[1] }

package Mock::Template;
sub output { '' }

package main;

use CGI qw(no_debug);
{
    my $p = bless { 'r' => Sledge::Request::CGI->new }, 'Mock::Pages';
    $p->register_hook(AFTER_OUTPUT => sub {
			  my $self = shift;
			  $self->{bar} = "baz";
		      });

    $p->output_content;

    is $p->{foo}, 'bar', 'class output_content hook';
    is $p->{bar}, 'baz', 'object output_content hook';
}

{
    my $p = bless { 'r' => Sledge::Request::CGI->new }, 'Mock::Pages';
    $p->output_content;

    is $p->{foo}, 'bar', 'class output_content hook';
    isnt $p->{bar}, 'baz', 'no object output_content hook';
}

