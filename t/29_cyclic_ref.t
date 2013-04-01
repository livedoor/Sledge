# $Id: 29_cyclic_ref.t,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use Test::More 'no_plan';

use CGI;
use Data::Dumper;

package Mock::Pages;
use base qw(Sledge::Pages::CGI);

use Sledge::Authorizer::Null;
use Sledge::SessionManager::Cookie;
use Sledge::Charset::Null;

sub construct_session { }

sub create_authorizer {
    my $self = shift;
    return Sledge::Authorizer::Null->new($self);
}

sub create_manager {
    my $self = shift;
    return Sledge::SessionManager::Cookie->new($self);
}

sub create_charset {
    my $self = shift;
    return Sledge::Charset::Null->new($self);
}

sub DESTROY {
    $::Message = "destroy called";
}

package main;

my $warnings;
local $SIG{__WARN__} = sub { $warnings .= "@_" };
{
    my $q = CGI->new({});
    my $p = Mock::Pages->new($q);

    my $dump = Dumper $p;
    my $count = $dump =~ s/VAR1/VAR1/g;
    is $count, 1, 'VAR1 appeared once. no cyclic ref';
}

is $::Message, 'destroy called';







