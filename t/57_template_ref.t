# $Id: 57_template_ref.t,v 1.1 2004/02/25 12:08:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@livedoor.jp>
# Livedoor, Co.,Ltd.
#

use strict;
use Test::More tests => 1;

use lib "t/lib";

package Mock::Pages;
use base qw(Sledge::TestPages);

my $data = <<DATA
Hello world!
DATA
    ;

sub dispatch_name {
    my $self = shift;
    $self->tmpl->set_option(filename => \$data);
}

use vars qw($TMPL_PATH);
$TMPL_PATH = "t/template";

package main;

my $p = Mock::Pages->new();
$p->dispatch("name");
like $p->output, qr/Hello world!/, $p->output;
