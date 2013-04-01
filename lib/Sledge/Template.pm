package Sledge::Template;
# $Id: Template.pm,v 1.2 2005/11/11 11:57:20 ikebe Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use HTML::Template;
use Sledge::Exceptions;

use vars qw($NSSepChar);
$NSSepChar = '/';

sub new {
    my($class, $file, $page) = @_;
    bless {
	_options => {
	    filename => $file,
	    associate => [ $page->r ],
	    die_on_bad_params => 0,
	    loop_context_vars => 1,
	    global_vars => 1,
	},
	_params => {},
	_assoc => {},
    }, $class;
}

sub param {
    my $self = shift;
    if (@_ == 0) {
	return keys %{$self->{_params}};
    }
    elsif (@_ == 1) {
	return $self->{_params}->{$_[0]};
    }
    else {
	while (my($key, $val) = splice @_, 0, 2) {
	    $self->{_params}->{$key} = $val;
	}
    }
}

sub add_associate {
    my($self, $obj) = @_;
    unless ($obj->can('param')) {
	Sledge::Exception::ParamMethodUnimplemented->throw(
	    sprintf('class %s has no param() method.', ref($obj)),
	);
    }
    push @{$self->{_options}->{associate}}, $obj;
}

sub associate_namespace {
    my($self, $namespace, $obj) = @_;
    $self->{_assoc}->{$namespace} = $obj;
}

sub _associate_dump {
    my $self = shift;
    while (my($ns, $obj) = each %{$self->{_assoc}}) {
	my %param = ref $obj eq 'HASH'
	    ? (map { $ns .$NSSepChar . $_ => $obj->{$_} } keys %$obj)
	    : (map { $ns . $NSSepChar . $_ => $obj->param($_) } $obj->param);
	$self->param(%param);
    }
}

sub set_option {
    my $self = shift;
    while (my($key, $val) = splice @_, 0, 2) {
	$self->{_options}->{$key} = $val;
    }
}

sub add_option {
    my $self = shift;
    while (my($key, $val) = splice @_, 0, 2) {
	if (! exists $self->{_options}->{$key}) {
	    $self->{_options}->{$key} = $val;
	}
        elsif (ref $self->{_options}->{$key} eq 'HASH') {
	    $self->{_options}->{$key} = {%{$self->{_options}->{$key}}, %{$val}};
	}
        elsif (ref $self->{_options}->{$key} eq 'ARRAY') {
	    push @{$self->{_options}->{$key}}, $val;
	}
	else {
	    $self->{_options}->{$key} = [ $self->{_options}->{$key}, $val ];
	}
    }
}

sub output {
    my $self = shift;
    $self->_associate_dump;
    unless (-e $self->{_options}->{filename}) {
	Sledge::Exception::TemplateNotFound->throw(
	    'No template file detected. Check your template path.',
	);
    }
    my $template = HTML::Template->new(%{$self->{_options}});
    $template->param(%{$self->{_params}});
    return $template->output;
}

1;

