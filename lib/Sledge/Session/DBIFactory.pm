package Sledge::Session::DBIFactory;
# $Id: DBIFactory.pm,v 1.1 2004/02/24 12:38:29 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@livedoor.jp>
# Livedoor, Co.,Ltd.
#

use strict;
use Sledge::Exceptions;
use UNIVERSAL::require;

use vars qw($DriverBindMap);
$DriverBindMap = {
    mysql  => 'Sledge::Session::MySQL',
    Pg     => 'Sledge::Session::Pg',
    SQLite => 'Sledge::Session::SQLite',
};

sub new {
    my($class, $page, $sid) = @_;
    my $config = $page->create_config;
    my @dsn = $config->datasource;
    my $driver = ($dsn[0] =~ /^dbi:(\w+)/i)[0]
	or Sledge::Exception::NoDriverName->throw($dsn[0]);
    my $session_class = $DriverBindMap->{$driver}
	or Sledge::Exception::SessionBindClassError->throw($driver);
    $session_class->require or Sledge::Exception::LoadingModuleError->throw($UNIVERSAL::require::ERROR);
    return $session_class->new($page, $sid);
}

1;
