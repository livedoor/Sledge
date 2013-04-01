use strict;
use Test::More;

my $Tests = 4;
plan tests => $Tests;

use CGI;
use Sledge::FillInForm;
use Sledge::Template;

{
    sub Mock::Pages::r { shift->{r} }
}

SKIP: {
    skip 'needs HTML::FillInForm 0.29', $Tests if $HTML::FillInForm::VERSION < 0.29;

    my $page = bless { r => CGI->new({ foo => 'bar', bar => 'baz' }) }, 'Mock::Pages';
    my $fill = Sledge::FillInForm->new($page);

    my $out = $fill->fillin(<<'EOF', $page);
<HTML><FORM><INPUT type="text" name="foo"><INPUT type="password" name="bar"></FORM></HTML>
EOF

    like $out, qr/value="bar"/, 'fillin';
    like $out, qr/value="baz"/, 'fillin';

    $fill = Sledge::FillInForm->new($page);
    $fill->ignore_fields([ 'bar' ]);
    my $out2 = $fill->fillin(<<'EOF', $page);
<HTML><FORM><INPUT type="text" name="foo"><INPUT type="text" name="bar"></FORM></HTML>
EOF

    like $out2, qr/value="bar"/, 'fillin';
    ok $out2 !~ /value="baz"/, 'no fillin for ignore_fields';
}



