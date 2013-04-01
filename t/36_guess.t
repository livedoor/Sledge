# $Id: 36_guess.t,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use Test::More tests => 3;

package Mock::Pages;
use base qw(Sledge::Pages::Base);

sub create_config {
    bless {}, 'Mock::Config';
}

package Mock::Pages::Bar;
use base qw(Mock::Pages);

__PACKAGE__->tmpl_dirname('bar');

package Mock::Config;
sub tmpl_path { '/path/to/tmpl' }

package main;

my $p1 = bless {}, 'Mock::Pages';
is $p1->guess_filename('foo'), '/path/to/tmpl/foo.html';

my $p2 = bless {}, 'Mock::Pages::Bar';
is $p2->guess_filename('foo'), '/path/to/tmpl/bar/foo.html';

my $p3 = bless {}, 'Mock::Pages::Bar';
is $p2->guess_filename('/foo'), '/path/to/tmpl/foo.html';



