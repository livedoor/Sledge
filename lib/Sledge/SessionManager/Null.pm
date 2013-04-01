package Sledge::SessionManager::Null;
# $Id: Null.pm,v 1.1 2004/02/25 07:47:12 miyagawa Exp $
#
# Masashi SEIKI
# Tatsuhiko Miyagawa
#

use strict;
use vars qw($VERSION);
$VERSION = 0.01;

use base qw(Sledge::SessionManager);

sub get_session {
    return Sledge::Session::RequestScope->new;
}

sub set_session { }

package Sledge::Session::RequestScope;
use base qw(Sledge::Session);

sub _load_session {
    my $self = shift;
    $self->{_sid} = $self->_gen_session_id;
    $self->{_new} = 1;
}

sub expire {
    my $self = shift;
    bless $self, 'Sledge::Session::Expired';
}

sub cleanup { }

sub DESTROY { }

1;

__END__

=head1 NAME

Sledge::SessionManager::Null - Null Session Manager

=head1 SYNOPSIS

  package MyProj::Pages;
  use Sledge::SessionManager::Null;

  sub create_manager {
      my $self = shift;
      Sledge::SessionManager::Null->new($self);
  }

=head1 DESCRIPTION

Sledge::SessionManager::Null is a Sledge SessionManager
implementation, which allows you to use session in a request
scope. You can use C<< $self->session >> without any cookie,
mod_rewrite and database stuff.

It can be handy for use in testing and prototyping etc.

=head1 AUTHOR

This module written by Masashi SEIKI in http://lists.sourceforge.jp/pipermail/sledge-users/2003-March/000050.html

Packaged into Sledge by Tatsuhiko Miyagawa.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl.

=head1 SEE ALSO

L<Sledge::SessionManager>

=cut

