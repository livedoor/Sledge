package Sledge::Constants;
# $Id: Constants.pm,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use base qw(Exporter);
@Sledge::Constants::EXPORT = qw(SUCCESS FAIL);

sub SUCCESS { 1 }
sub FAIL    { !SUCCESS }

1;
