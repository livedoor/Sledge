package Sledge::Authorizer::Null;
# $Id: Null.pm,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use base qw(Sledge::Authorizer);

sub authorize {
    my($self, $page) = @_;
    return;
}

1;
