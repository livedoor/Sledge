package Sledge::Install;
# $Id: Install.pm,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use base qw(Class::Accessor);
__PACKAGE__->mk_accessors(qw(project opt));

use Sledge::Install::Stub;

sub new {
    my($class, $project, $opt) = @_;
    bless { project => $project, opt => $opt }, $class;
}

sub setup {
    my $self = shift;
    for my $file (Sledge::Install::Stub->files) {
	my $stub = Sledge::Install::Stub->new($file, $self);
	$stub->create_file;
    }
}

1;
