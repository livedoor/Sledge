package Sledge::Charset::Null;
# $Id: Null.pm,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use base qw(Sledge::Charset);

sub convert_param {
    my($self, $page) = @_;
    return;
}

sub content_type {
    return 'text/html';
}

sub output_filter {
    my $self = shift;
    return @_;
}

1;
