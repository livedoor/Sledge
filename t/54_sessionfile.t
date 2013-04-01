# $Id: 54_sessionfile.t,v 1.2 2004/02/24 13:00:35 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.jp>
# EDGE, Co.,Ltd.
#

use strict;
use Test::More;

plan tests => 4;

use lib "t/lib";

package Mock::Pages;
use base qw(Sledge::TestPages);
use Sledge::Session::File;
use File::Temp qw(tempdir);

sub create_session {
    Sledge::Session::File->new(@_);
}

sub dispatch_foo {
    my $self = shift;
    $self->session->param(foo => "bar");
}

my $tempdir = tempdir(CLEANUP => 1);

used_only_once($Mock::Pages::SESSION_DIR, $Mock::Pages::TMPL_PATH, $Mock::Pages::COOKIE_NAME);

$Mock::Pages::SESSION_DIR = $tempdir;
$Mock::Pages::TMPL_PATH   = "t/template";
$Mock::Pages::COOKIE_NAME = "sid";

sub used_only_once { }

package main;
use FileHandle;
use File::Spec;
use Storable;

my $p = Mock::Pages->new();
$p->dispatch("foo");

my($sid) = $p->output =~ /sid=(\w+)/;

my $session = File::Spec->catfile($tempdir, "Sledge-Session-$sid");
ok -e $session, "$session exists";

my $fh = FileHandle->new($session);
ok $fh, "can read $session";

my $body = do { local $/; <$fh> };
my $data = Storable::thaw($body);

is $data->{_url}, "http://localhost/";
is $data->{foo}, "bar";


