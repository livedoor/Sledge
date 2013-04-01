package Sledge::Pages::Compat;
# $Id: Compat.pm,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use constant MOD_PERL => defined $ENV{MOD_PERL};

sub import {
    my $base = MOD_PERL ? 'Sledge::Pages::Apache' : 'Sledge::Pages::CGI';
    eval qq{require $base};
    {
	my $pkg = caller;
	no strict 'refs';
	unshift @{"$pkg\::ISA"}, $base;
    }
}

1;
