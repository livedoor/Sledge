package Sledge::Install::Stub;
# $Id: Stub.pm,v 1.3 2004/02/24 12:42:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use base qw(Class::Accessor);
__PACKAGE__->mk_accessors(qw(file install));

use File::Basename;
use File::Path;
use FileHandle;

use vars qw(%Skelton);

sub files {
    return keys %Skelton;
}

sub get_template {
    my $self = shift;
    return $Skelton{$self->file};
}

sub new {
    my($class, $file, $install) = @_;
    bless { file => $file, install => $install }, $class;
}

sub as_string {
    my $self = shift;
    my $template = $self->get_template;
    $template =~ s/__PROJECT__/$self->install->project/eg;
    $template =~ s/__OPT_(.*?)__/$self->install->opt->{lc($1)}/eg;
    return $template;
}

sub create_file {
    my $self = shift;
    my $pm = sprintf '%s/%s', $self->install->project, $self->file;
    unless (-e dirname($pm)) {
	mkpath dirname($pm), 1, 0755;
    }

    if (-e $pm) {
	my $backup = $pm . '.orig';
	warn "$pm exists. backuped to $backup\n";
	rename $pm, $backup;
    }

    my $output = FileHandle->new(">$pm");
    $output->print($self->as_string);
}

#--------------------------------------------------
# Skelton goes from here
#--------------------------------------------------

$Skelton{'Pages.pm'} = <<'EOS';
package __PROJECT__::Pages;
use strict;
use Sledge::Pages::Compat;

use Sledge::Authorizer::Null;
use Sledge::Charset::Default;
use Sledge::SessionManager::Cookie;
use Sledge::Session::MySQL;
use Sledge::Template::TT;

use __PROJECT__::Config;

sub create_authorizer {
    my $self = shift;
    return Sledge::Authorizer::Null->new($self);
}

sub create_charset {
    my $self = shift;
    return Sledge::Charset::Default->new($self);
}

sub create_config {
    my $self = shift;
    return __PROJECT__::Config->instance;
}

sub create_manager {
    my $self = shift;
    return Sledge::SessionManager::Cookie->new($self);
}

sub create_session {
    my($self, $sid) = @_;
    return Sledge::Session::MySQL->new($self, $sid);
}

1;
EOS
    ;

$Skelton{'Config.pm'} = <<'EOS';
package __PROJECT__::Config;
use strict;

use base qw(Sledge::Config Class::Singleton);

sub case_sensitive { 0 }

sub _new_instance {
    my $class = shift;
    unless (defined $ENV{SLEDGE_CONFIG_NAME}) {
        do '/etc/__PROJECT__-conf.pl' or warn $!;
    }
    $class->SUPER::new($ENV{SLEDGE_CONFIG_NAME});
}

1;
EOS
    ;

$Skelton{'Config/_common.pm'} = <<'EOS';
package __PROJECT__::Config::_common;
use strict;
use vars qw(%C);
*Config = \%C;

$C{TMPL_PATH}     = '/path/to/tmpl_dir';
$C{DATASOURCE}    = [ 'dbi:mysql:sledge','root', '' ];
$C{COOKIE_NAME}   = 'sledge_sid';
$C{COOKIE_PATH}   = '/';
$C{COOKIE_DOMAIN} = undef;

1;
EOS
    ;

1;
