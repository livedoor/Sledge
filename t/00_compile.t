# $Id: 00_compile.t,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use Test::More;

use File::Find;

my @mod;
find(\&wanted, 'lib');

plan tests => scalar @mod;
require_ok $_ for @mod;

sub wanted {
    if (/\.pm$/) {
	my $module = $File::Find::name;
	$module =~ s@^lib/(.*)\.pm$@$1@;
	$module =~ s@/@::@g;
	push @mod, $module;
    }
}
