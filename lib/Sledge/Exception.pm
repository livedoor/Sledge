package Sledge::Exception;
# $Id: Exception.pm,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use Error 0.15;
use base qw(Error::Simple Class::Data::Inheritable);
__PACKAGE__->mk_classdata('do_trace');

use overload 'bool' => sub { 1 };

# borrowed from Axkit::Exception
sub new {
    my $class = shift;
    my @args  =	@_ ? @_ : ($class->description);
    local $Error::Depth = $Error::Depth + 1;
    my $self  = $class->SUPER::new(@args);

    if ($class->do_trace) {
        my $i = $Error::Depth + 1;
        my($pkg, $file, $line) = caller($i++);
        my @stacktrace;
        while ($pkg) {
            push @stacktrace, Sledge::Exception::StackTrace->new(
		pkg  => $pkg,
		file => $file,
		line => $line,
	    );
            ($pkg, $file, $line) = caller($i++);
        }
	pop @stacktrace;
        $self->{'-stacktrace'} = \@stacktrace;
    }
    return $self;
}

sub stacktrace {
    my $self = shift;
    return $self->{'-stacktrace'} || [];
}

sub description { 'Sledge core exception (Abstract)' }

package Sledge::Exception::StackTrace;

sub new {
    my($class, %p) = @_;
    bless \%p, $class;
}

sub pkg  { shift->{pkg} }
sub file { shift->{file} }
sub line { shift->{line} }

1;
