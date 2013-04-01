package Sledge::Pages::CGI;
# $Id: CGI.pm,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use base qw(Sledge::Pages::Base);

use CGI;
use Sledge::Request::CGI;

sub create_request {
    my($self, $query) = @_;
    return Sledge::Request::CGI->new($query || CGI->new);
}

1;

