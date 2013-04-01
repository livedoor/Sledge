use strict;
use Test::More tests => 3;

use Cwd;
use File::Temp qw(tempdir);

my $dir = cwd;
my $tmp = tempdir(CLEANUP => 1);
chdir $tmp;

use Sledge::Install;
Sledge::Install->new('TestProj', { pages => 'Apache' })->setup;
chdir $dir;

delete $ENV{TMPDIR};

push @INC, $tmp;
use_ok('TestProj::Pages');
use_ok('TestProj::Config');

ok(TestProj::Pages->isa('Sledge::Pages::CGI'));
