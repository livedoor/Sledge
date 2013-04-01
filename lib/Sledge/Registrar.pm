package Sledge::Registrar;
# $Id: Registrar.pm,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use Sledge::Exceptions;

sub context { Sledge::Exception::NoContextRunning->throw }

1;


