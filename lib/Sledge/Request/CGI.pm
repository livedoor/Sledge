package Sledge::Request::CGI;
# $Id: CGI.pm,v 1.2 2004/02/23 09:19:13 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use base qw(Class::Accessor);
__PACKAGE__->mk_accessors(qw(query header_hash));

use vars qw($AUTOLOAD);

use Sledge::Request::Table;
use Sledge::Request::Upload;

sub new {
    my($class, $query) = @_;
    bless { query => $query, header_hash => {} }, $class;
}

sub header_out {
    my($self, $key, $value) = @_;
    $self->header_hash->{$key} = $value if @_ == 3;
    $self->header_hash->{$key};
}

sub headers_out {
    my $self = shift;
    return wantarray ? %{$self->header_hash}
	: Sledge::Request::Table->new($self->header_hash);
}

sub header_in {
    my($self, $key) = @_;
    $key =~ s/-/_/g;
    return $ENV{"HTTP_" . uc($key)};
}

sub content_type {
    my($self, $type) = @_;
    $self->header_out('Content-Type' => $type);
}

sub send_http_header {
    my $self = shift;
    my %header = %{$self->{header_hash}};
    for my $key (keys %header) {
	if (ref $header{$key} eq 'ARRAY') {
	    print "$key: $_\n" for @{$header{$key}};
	}
	else {
	    print "$key: ", $header{$key}, "\n";
	}
    }
    print "\n";
}

sub method {
    return $ENV{REQUEST_METHOD} || 'GET';
}

sub status {
    my($self, $status) = @_;
    $self->header_out(Status => $status);
}

sub print {
    my $self = shift;
    CORE::print(@_);
}

sub uri {
    # $REQUEST_URI - Query String
    my $uri = $ENV{REQUEST_URI};
    $uri =~ s/\?.*$//;
    return $uri;
}

sub args {
    return $ENV{QUERY_STRING};
}

sub upload {
    my $self = shift;
    Sledge::Request::Upload->new($self, @_);
}

sub param {
    my $self = shift;

    # $r->param(foo => \@bar);
    if (@_ == 2 && ref($_[1]) eq 'ARRAY') {
	return $self->query->param($_[0], @{$_[1]});
    }
    $self->query->param(@_);
}

sub DESTROY { }

sub AUTOLOAD {
    my $self = shift;
    (my $meth = $AUTOLOAD) =~ s/.*:://;
    $self->query->$meth(@_);
}

1;
