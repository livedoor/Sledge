# $Id: 56_sessionmanager_null.t,v 1.1 2004/02/25 07:47:13 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@livedoor.jp>
# Livedoor, Co.,Ltd.
#

use strict;
use Test::More;

plan tests => 2;

use lib "t/lib";
package Mock::Pages;
use base qw(Sledge::TestPages);

use Sledge::SessionManager::Null;

sub create_manager {
    Sledge::SessionManager::Null->new(shift);
}

sub dispatch_name {
    my $self = shift;
    $self->session->param(var => "blah");
}

use vars qw($TMPL_PATH $COOKIE_NAME);

$TMPL_PATH = "t/template";
$COOKIE_NAME = "sid";

package main;

my $p = Mock::Pages->new();
$p->dispatch("name");

like $p->output, qr/blah/;
unlike $p->output, qr/sid=/;
