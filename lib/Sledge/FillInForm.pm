package Sledge::FillInForm;
# $Id: FillInForm.pm,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use HTML::FillInForm;
use Sledge::Exceptions;

use base qw(Class::Accessor);
__PACKAGE__->mk_accessors(qw(fif fobject fdat target ignore_fields));

use vars qw($FillPassword);
$FillPassword = 1;

sub new {
    my($class, $page) = @_;
    bless {
	fif     => HTML::FillInForm->new,
	fobject => [ $page->r ],
	fdat    => undef,
	target  => undef,
	ignore_fields => [],
    };
}

sub fillin {
    my($self, $html, $page) = @_;
    my %options = (
	scalarref => \$html,
	target    => $self->target,
	fill_password => $FillPassword,
	ignore_fields => $self->ignore_fields,
    );
    if ($self->fdat) {
	$options{fdat} = $self->fdat;
    } elsif ($self->fobject) {
	$options{fobject} = $self->fobject;
    }

    return $self->fif->fill(%options);
}

sub add_fobject {
    my($self, $obj) = @_;
    unless ($obj->can('param')) {
	Sledge::Exception::ParamMethodUnimplemented->throw(
	    sprintf('Class %s has no param() method!', ref $obj),
	);
    }
    push @{$self->{fobject}}, $obj;
}

1;
