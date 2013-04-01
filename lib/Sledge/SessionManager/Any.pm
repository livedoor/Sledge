package Sledge::SessionManager::Any;
# $Id: Any.pm,v 1.1 2004/02/24 08:51:14 miyagawa Exp $
#
# IKEBE Tomohiro <ikebe@livedoor.jp>
# Livedoor, Co.,Ltd.
#

use strict;
use base qw(Sledge::SessionManager);
use HTML::StickyQuery 0.10;
use CGI::Cookie;
use URI;

sub import {
    my $class = shift;
    my $pkg   = caller(0);
    no strict 'refs';
    *{"$pkg\::redirect"} = \&redirect_filter;
}

sub redirect_filter {
    my($self, $path, $scheme) = @_;
    my $super = 'Sledge::Pages::Base::redirect';
    if ($path =~ /^http/ || $self->manager->get_sid_from_cookie($self)) {
	# redirect to other server!
	return $self->$super($path, $scheme);
    }
    my $uri = URI->new($path);
    my $config = $self->create_config;
    # XXX Sledge::Session::Expired
    unless ($self->session->isa('Sledge::Session::Expired')) {
	$uri->query_form($uri->query_form, 
			 $config->cookie_name => $self->session->session_id);
    }
    return $self->$super($uri->as_string, $scheme);
}

sub new {
    my($class, $page) = @_;
    my $self = $class->SUPER::new($page);
    # use filter or not.
    unless ($self->get_sid_from_cookie($page)) {
	$page->add_filter(\&sid_filter);
    }
    return $self;
}

sub get_session_id {
    my($self, $page) = @_;
    return $self->get_sid_from_cookie($page) || $self->get_sid_from_param($page);
}

sub get_sid_from_cookie {
    my($self, $page) = @_;
    my $config = $page->create_config;
    my %jar    = CGI::Cookie->fetch;
    my $cookie = $jar{$config->cookie_name};
    return $cookie ? $cookie->value : undef;
}

sub get_sid_from_param {
    my($self, $page) = @_;
    $self->{_use_cookie} = 0;
    my $config = $page->create_config;
    my $sid = $page->r->param($config->cookie_name);
    return $sid;
}

sub set_session_id { 
    my($self, $page, $sid) = @_;
    # set Cookie.
    $self->set_sid_as_cookie($page, $sid);
}

sub set_sid_as_cookie {
    my($self, $page, $sid) = @_;
    my $config = $page->create_config;
    my %options = (
	-name   => $config->cookie_name,
        -value  => $sid,
        -path   => $config->cookie_path,
    );
    $options{'-domain'} = $config->cookie_domain if $config->cookie_domain;
    my $cookie = CGI::Cookie->new(%options);
    $page->r->header_out('Set-Cookie' => $cookie->as_string);
}

sub sid_filter {
    my($self, $content) = @_;
    my $config = $self->create_config;
    my $sid_name = $config->cookie_name;
    my $sid = $self->r->param($sid_name) || $self->session->session_id;
    # XXX we need HTML::StickyAny or something ...
    $content =~ s/(<form\s*.*?>)/$1\n<input type="hidden" name="$sid_name" value="$sid">/isg;

    my $sticky = HTML::StickyQuery->new;
    return $sticky->sticky(
	scalarref => \$content,
	param => { $sid_name => $sid },
    );
}

1;

__END__
