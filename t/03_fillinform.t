use strict;
use Test::More tests => 5;

use CGI;
use Sledge::FillInForm;
use Sledge::Template;

{
    sub Dummy::Pages::r { shift->{r} }
}

{
    my $page = bless { r => CGI->new({ foo => 'bar' }) }, 'Dummy::Pages';
    my $fill = Sledge::FillInForm->new($page);
    ok $fill->isa('Sledge::FillInForm'), 'new';

    ok eq_array($fill->fobject, [ $page->r ]), 'fobject init';

    my $out = $fill->fillin(<<'EOF', $page);
<HTML><FORM><INPUT type="text" name="foo"></FORM></HTML>
EOF
    like $out, qr/value="bar"/i, 'fillin';

    $fill->target('baz');
    $out = $fill->fillin(<<'EOF', $page);
<HTML><FORM name="baz"><INPUT type="text" name="foo"></FORM></HTML>
EOF
    like $out, qr/value="bar"/i, 'fillin target';

    $fill->fdat({ foo => 'baz' });
    $out = $fill->fillin(<<'EOF', $page);
<HTML><FORM name="baz"><INPUT type="text" name="foo"></FORM></HTML>
EOF
    like $out, qr/value="baz"/i, 'fillin target';
}



