package Sledge;
# $Id: Sledge.pm,v 1.4 2004/02/24 08:51:14 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use vars qw($VERSION $CODENAME);

$VERSION  = "1.11";
$CODENAME = "The Next Big Thing";

sub handler {
    my $r = shift;
    # Umm this doesn't work!
    Apache::add_version_component("Sledge/$VERSION ($CODENAME)");
}

1;
__END__

=head1 NAME

Sledge - Open Source Web Application Framework in Perl

=head1 AUTHORS

Tatsuhiko Miyagawa with many help from (listed in alphabetically):

  Akihiro Tsukui
  Atsushi Baba
  Eijiro Koike
  Hideoki Yoshikawa
  Hiroyuki Kobayashi
  Hiroyuki Oyama
  Kazuhiro Nakata
  Kensaku Fujiwara
  Ko-hei Ohtsuka
  Makoto Hasegawa
  Masashi Seiki
  Naoto Ishikawa
  Satoshi Tanimoto
  Shinya Hayakawa
  Shohei Tsunoda
  Takahiro Ohmori
  Takefumi Kimura
  Taro Sakamoto
  Tomohiro Ikebe
  Toyoo Kobayashi
  Yoshiharu Matsushima
  Yoshiki Kurihara

=cut
