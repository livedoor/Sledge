package Sledge::Charset;
# $Id: Charset.pm,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use base qw(Class::Accessor);

use Sledge::Exceptions;

sub new {
    my($class, $page) = @_;
    bless {}, $class;
}

sub convert_param { Sledge::Exception::AbstractMethod->throw }
sub content_type  { Sledge::Exception::AbstractMethod->throw }
sub output_filter { Sledge::Exception::AbstractMethod->throw }

1;
