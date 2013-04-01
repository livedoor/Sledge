# $Id: 55_session_factory.t,v 1.1 2004/02/24 12:38:29 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@livedoor.jp>
# Livedoor, Co.,Ltd.
#

use strict;
use Test::More;

plan tests => 4;

fake_modules("Sledge::Session::MySQL", "Sledge::Session::Pg", "Sledge::Session::SQLite");

use lib "t/lib";

package Mock::Pages;
use base qw(Sledge::TestPages);

use Sledge::Session::DBIFactory;
sub create_session {
    my $self = shift;
    return Sledge::Session::DBIFactory->new($self, @_);
}

package main;

do_test("dbi:mysql:test", 'Sledge::Session::MySQL');
do_test("dbi:Pg:db=foo", 'Sledge::Session::Pg');
do_test("dbi:SQLite:db=foo", 'Sledge::Session::SQLite');
do_test("dbi:blahblah", 'blahblah at .*/DBIFactory\.pm');


sub fake_modules {
    for my $module (@_) {
	no strict 'refs';
	@{"$module\::ISA"} = qw(Mock::Session);
	(my $f = $module) =~ s!::!/!g;
	$INC{"$f.pm"} = __PACKAGE__;
    }
}

sub do_test {
    my($dsn, $class) = @_;
    my $dummy = $Mock::Pages::DATASOURCE;
    local $Mock::Pages::DATASOURCE = [ $dsn, "blah", "blah" ];
    my $p = Mock::Pages->new();
    eval { $p->dispatch("foo") };
    like $@, qr/$class/, "$dsn => $class";
}

package Mock::Session;

sub new {
    my $class = shift;
    die $class;
}
