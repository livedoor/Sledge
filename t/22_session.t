# $Id: 22_session.t,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use Test::More 'no_plan';
use Sledge::Session;

my $session = bless {}, 'Sledge::Session';

# public API
for my $meth (qw(param remove expire session_id is_fresh)) {
    can_ok $session, $meth;
}

# developer API
for my $meth (qw(_connect_database _do_lock _lockid _select_me _insert_me _update_me _delete_me)) {
    eval {
	$session->$meth();
	fail "no exception";
    };
    isa_ok $@, 'Sledge::Exception::AbstractMethod';
}

local $^W;
*Sledge::Session::DESTROY = sub { };


