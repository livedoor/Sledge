package Sledge::TestPages;
# $Id: TestPages.pm,v 1.4 2004/02/25 12:08:37 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use Sledge::Pages::Compat;
use Sledge::Authorizer::Null;
use Sledge::SessionManager::Cookie;
use Sledge::Charset::Default;
use Sledge::Template::TT;
use IO::Scalar;

$ENV{HTTP_HOST}    = 'localhost';
$ENV{REQUEST_URI}  = '/';
$ENV{QUERY_STRING} = '';

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
    return Sledge::Charset::Default->new($self);
}

sub create_config {
    my $self = shift;
    return Sledge::TestConfig->new($self);
}

sub create_session {
    my $self = shift;
    return Sledge::TestSession->new($self, @_);
}

sub dispatch {
    my $self = shift;
    CGI::initialize_globals();
    tie *STDOUT, 'IO::Scalar', \my $out;
    $self->SUPER::dispatch(@_);
    untie *STDOUT;
    bless $self, __PACKAGE__;
    $self->{output} = $out;
}

sub output { shift->{output} }

package Sledge::TestConfig;
use vars qw($AUTOLOAD $DefaultVars);

$DefaultVars = {
    COOKIE_NAME => "sledge_sid",
};

sub new {
    my($class, $proto) = @_;
    bless { pkg => ref $proto || $proto }, $class;
}

sub DESTROY { }

sub AUTOLOAD {
    my $self = shift;
    my $pkg = $self->{pkg};
    (my $method = $AUTOLOAD) =~ s/.*://;
    no strict 'refs';
    my $glob = *{"$pkg\::" . uc($method)}{SCALAR};
    my $val = defined($$glob) ? ${"$pkg\::" . uc($method)}
	: $DefaultVars->{uc($method)};
    return (ref($val) eq 'ARRAY' && wantarray) ? @$val : $val;
}

package Sledge::TestSession;
use base qw(Sledge::Session);

sub _connect_database    { }
sub _commit              { }
sub _do_lock             { }
sub _lockid              { }

my %session;
sub _select_me {
    my $self = shift;
    $self->{_data} = $session{$self->session_id};
}

sub _insert_me {
    my $self = shift;
    $session{$self->session_id} = $self->{_data};
}

sub _update_me {
    my $self = shift;
    $session{$self->session_id} = $self->{_data};
}

sub _delete_me {
    my $self = shift;
    delete $session{$self->session_id};
}

1;
