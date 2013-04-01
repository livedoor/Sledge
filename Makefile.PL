use strict;
use ExtUtils::MakeMaker;
use FileHandle;

check_version();
check_warnings_pm();

my %prereq = read_prereq();

WriteMakefile(
    'NAME'      => 'Sledge',
    'VERSION_FROM' => 'lib/Sledge.pm', # finds $VERSION
    'EXE_FILES'  => [ 'bin/sledge-setup' ],
    'PREREQ_PM' => \%prereq,
);

sub read_prereq {
    my $handle  = FileHandle->new("eg/prereq-modules");
    my %modules = map { chomp; my($mod, $ver) = split / /; ($mod, $ver || 0) } $handle->getlines;
    return %modules;
}

sub check_warnings_pm {
    my $file = "lib/warnings.pm";
    if ($] < 5.006) {
	open OUT, ">$file";
	print OUT <<MOD;
package warnings;
sub import { }
sub unimport { }
1;
MOD
    ;
        close OUT;
    } else {
        unlink $file if -e $file;
    }
}

sub check_version {
    my $current_version;
    eval {
	require Sledge;
	$current_version = Sledge->VERSION;
    };

    require "lib/Sledge.pm";
    if ($current_version && $current_version < $Sledge::VERSION) {
	warn <<WARN;

NOTE: This server already has Sledge $current_version installed.

Are you sure upgrading it to $Sledge::VERSION?
See Changes for details of what has been changed since $current_version.

WARN
    ;
	sleep 1;
    }
}
