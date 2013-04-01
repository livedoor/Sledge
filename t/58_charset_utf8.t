# $Id: 58_charset_utf8.t,v 1.1 2004/02/25 12:08:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@livedoor.jp>
# Livedoor, Co.,Ltd.
#

use strict;
use Test::More "no_plan";
use lib "t/lib";

package Mock::Pages;
use base qw(Sledge::TestPages);
use Sledge::Charset::UTF8;

sub create_charset {
    Sledge::Charset::UTF8->new(@_);
}

sub dispatch_unicode { }

use vars qw($TMPL_PATH);
$TMPL_PATH = "t/template";

package main;

my $p = Mock::Pages->new();
$p->dispatch("unicode");

use Jcode;

my $str = Jcode->new("¤Æ¤¹¤È")->utf8;
like $p->output, qr/$str/;
