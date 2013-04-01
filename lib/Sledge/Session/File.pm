package Sledge::Session::File;
# $Id: File.pm,v 1.2 2004/02/24 12:47:46 miyagawa Exp $
#
# IKEBE Tomohiro <ikebe@livedoor.jp>
# Livedoor, Co.,Ltd.
#

use strict;
use base qw(Sledge::Session);

use FileHandle;
use File::Spec;
use Fcntl qw(:flock);
use Sledge::Exceptions;

sub _connect_database    { 
    my($self, $page) = @_;
    my $config = $page->create_config;
    my $dir = eval { $config->session_dir } || '/tmp';
    # for session cleanup plugin
    return $dir unless ref $self;
    my $file = sprintf '%s/Sledge-Session-%s', $dir, $self->{_sid};
    $self->{__filename} = $file;
    my $fh = FileHandle->new($file, O_RDWR|O_CREAT) 
	or Sledge::Exception::DBConnectionError->throw($!);
    return $fh;
}

sub _select_me { 
    my($self, $opt) = @_;
    my $fh = $self->{_dbh};
    flock($fh, LOCK_SH);
    $fh->seek(0, 0);
    my $data;
    while (<$fh>) {
	$data .= $_;
    }
    flock($fh, LOCK_UN);
    $self->{_data} = $self->_deserialize($data);
}

sub _insert_me {
    my $self = shift;
    my $fh = $self->{_dbh};
    flock($fh, LOCK_EX);
    $fh->truncate(0);
    $fh->seek(0, 0);
    $fh->print($self->_serialize($self->{_data}));
    flock($fh, LOCK_UN);
}

sub _update_me { shift->_insert_me; }
sub _delete_me { unlink shift->{__filename}; }

sub _commit {
    my $self = shift;
    $self->{_dbh}->close if $self->{_dbh};
}
sub _do_lock {}
sub _lockid {}
sub _do_cleanup { 
    my($self, $dir, $min) = @_;
    # XXX insecure?
    unlink $_ for
	grep { _mtime($_) < time - $min * 60 } glob "$dir/Sledge-Session-*";
}

sub _mtime { (stat(shift))[9] }


1;

__END__

=head1 NAME

Sledge::Session::File - file-based Session storage

=head1 SYNOPSIS

  package Proj::Pages;
  use Sledge::Session::File;

  sub create_session {
      my($self, $sid) = @_;
      return Sledge::Session::File->new($self, $sid);
  }

  # in Config
  $C{SESSION_DIR} = "/path/to/session_dir";

=head1 DESCRIPTION

Sledge::Session::File is a Session implementation that uses flat-file
to save session data in. file name is Session ID, modified time is
mtime and session data is serialized into flat-file using Storable.

=head1 AUTHOR

Tomohiro Ikebe E<lt>ikebe@livedoor.jpE<gt>

Tatsuhiko Miyagawa E<lt>miyagawa@livedoor.jpE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Sledge.

=head1 SEE ALSO

L<Sledge>

=cut
