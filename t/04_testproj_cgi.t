use strict;
use Test::More tests => 4;

use Cwd;
use File::Temp qw(tempdir);

my $dir = cwd;
my $tmp = tempdir(CLEANUP => 1);
chdir $tmp;

use Sledge::Install;
Sledge::Install->new('TestProj', { pages => 'CGI' })->setup;
chdir $dir;

push @INC, $tmp;
delete $ENV{TMPDIR};
use_ok('TestProj::Pages');
use_ok('TestProj::Config');
ok(TestProj::Config->isa('Sledge::Config'));
ok(TestProj::Pages->isa('Sledge::Pages::CGI'));

