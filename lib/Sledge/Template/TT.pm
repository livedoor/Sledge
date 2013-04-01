package Sledge::Template::TT;
# $Id: TT.pm,v 1.3 2004/02/25 12:08:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use vars qw($VERSION);
$VERSION = 0.03;

use base qw(Sledge::Template);

use Template;
use Sledge::Exceptions;

sub import {
    my $class = shift;
    my $pkg = caller(0);
    no strict 'refs';
    *{"$pkg\::create_template"} = sub {
	my($self, $file) = @_;
	return $class->new($file, $self);
    };
}

sub new {
    my($class, $file, $page) = @_;
    bless {
	_options => {
	    filename => $file,
	    ABSOLUTE => 1,
	    RELATIVE => 1,
	    INCLUDE_PATH => [ $page->create_config->tmpl_path, '.' ],
	},
	_params  => {
	    config  => $page->create_config,
	    r       => $page->r,
	    session => $page->session,
	},
    }, $class;
}

sub add_associate       { Sledge::Exception::UnimplementedMethod->throw }
sub associate_namespace { Sledge::Exception::UnimplementedMethod->throw }

sub output {
    my $self = shift;
    my %config = %{$self->{_options}};
    my $input  = delete $config{filename};
    my $template = Template->new(\%config);
    unless (ref($input) || -e $input) {
	Sledge::Exception::TemplateNotFound->throw(
	    "No template file detected: $input",
	);
    }
    $template->process($input, $self->{_params}, \my $output)
	or Sledge::Exception::TemplateParseError->throw($template->error);
    return $output;
}

1;
