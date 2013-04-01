package Sledge::Request::Upload;
# $Id: Upload.pm,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use base qw(Class::Accessor);
__PACKAGE__->mk_accessors(qw(req name fh));

use Sledge::Request::Table;

sub new {
    my($class, $req, $name) = @_;
    return $class->_new_from_name($req, $name) if defined $name;
    return $class->_new_list($req);
}

sub _new_list {
    my($class, $req) = @_;

    my @names = $class->_param_names($req);
    return wantarray
	? map $class->_new_from_name($req, $_), @names
	    : $class->_new_from_name($names[0]);
}

sub _new_from_name {
    my($class, $req, $name) = @_;
    my $upload = $req->query->upload($name) or return;
    bless {
	req  => $req,
	name => $name,
	fh   => $upload,
    }, $class;
}

sub _param_names {
    my($class, $req) = @_;
    return grep ref($req->param($_)), $req->param;
}

sub filename {
    my $self = shift;
    return scalar $self->req->query->param($self->name);
}

sub size {
    my $self = shift;
    return -s $self->fh;
}

sub info {
    my($self, $key) = @_;

    my %info = %{$self->req->query->uploadInfo($self->filename)}; # deref
    delete $info{'Content-Length'}; # XXX Apache::Request does not have
    return defined $key
	? $info{$key} : Sledge::Request::Table->new(\%info);
}

sub type {
    my $self = shift;
    return $self->info('Content-Type');
}

sub next {
    my $self = shift;
    my $class = ref $self;
    my @names = $class->_param_names($self->req);
    my %name2idx = map { $names[$_] => $_ } 0..$#names;

    my $next_idx = $name2idx{$self->name} + 1;
    return $next_idx > $#names
	? undef : $class->_new_from_name($self->req, $names[$next_idx]);
}

sub tempname {
    my $self = shift;
    return $self->req->query->tmpFileName($self->fh);
}

sub link {
    my($self, $path) = @_;
    link $self->tempname, $path;
}

1;

