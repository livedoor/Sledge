package Sledge::Request::Table;
# $Id: Table.pm,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use Sledge::Exceptions;

sub new {
    my($class, $hashref) = @_;
    unless (ref $hashref eq 'HASH') {
	Sledge::Exception::ArgumentTypeError->throw(
	    "argument should be hashref",
	);
    }

    # not copy of the hash
    bless $hashref, $class;
}

sub get {
    my($self, $key) = @_;
    return exists $self->{$key} && ref($self->{$key}) eq 'ARRAY'
	? @{$self->{$key}} : $self->{$key};
}

sub set {
    my($self, $key, $val) = @_;
    $self->{$key} = $val;
}

sub unset {
    my($self, $key) = @_;
    delete $self->{$key};
}

sub clear {
    my $self = shift;
    %$self = ();
}

sub add {
    my $self = shift;
    while (my($key, $val) = splice @_, 0, 2) {
	if (!exists $self->{$key}) {
	    $self->{$key} = $val;
	}
	elsif (ref $self->{$key} ne 'ARRAY') {
	    $self->{$key} = [ $self->{$key}, $val ];
	}
	else {
	    push @{$self->{$key}}, $val;
	}
    }
}

1;
