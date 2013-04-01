package Sledge::SessionManager;
# $Id: SessionManager.pm,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
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

sub get_session_id { Sledge::Exception::AbstractMethod->throw }
sub set_session_id { Sledge::Exception::AbstractMethod->throw }

sub get_session {
    my($self, $page) = @_;

    # If there is no session, it constructs fresh one
    my $sid = $self->get_session_id($page);
    my $session;
    if ($sid) {
	eval { $session = $page->create_session($sid); };
	if (my $E = $@) {
	    if (ref($E) && $E->isa('Sledge::Exception::SessionIdNotFound')) {
		$session = $page->create_session;
	    } else {
		die $E;		# should be rethrow
	    }
	}
    } else {
	$session = $page->create_session;
    }

    # store time and URL
    $session->param(_timestamp => time);
    $session->param(_url       => $page->current_url);
    return $session;
}

sub set_session {
    my($self, $page, $session) = @_;
    $self->set_session_id($page, $session->session_id);
}


1;
