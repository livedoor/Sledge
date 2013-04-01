# $Id: 30_upload.t,v 1.2 2003/02/16 14:33:49 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use Test::More 'no_plan';

use CGI;
use FileHandle;
use HTTP::Request::Common;
use IO::Scalar;
use Sledge::Request::CGI;

# simulates file upload
my $req = POST '/foo.cgi',
    Content_Type => 'form-data',
    Content => [
	name => 'miyagawa',
	file1 => [ 't/upload.txt' ],
	file2 => [ 't/baz.html' ],
    ];

my $post = $req->as_string;

$post =~ s/^POST.*\n//;
$post =~ s
    {^Content-Length: (\d+)\n}
    {$ENV{CONTENT_LENGTH} = $1; ""}e;
$post =~ s
    {^Content-Type: (.*)\n\n}
    {$ENV{CONTENT_TYPE} = $1; ""}e;

$ENV{REQUEST_METHOD} = 'POST';
$ENV{HTTP_USER_AGENT} = 'mozilla';

tie *STDIN, 'IO::Scalar', \$post;
my $q = CGI->new;
my $r = Sledge::Request::CGI->new($q);

{
    ok my $upload = $r->upload('file1');
    isa_ok $upload, 'Sledge::Request::Upload';
    is $upload->name, 'file1';
    is $upload->filename, 'upload.txt';

    my $fh = $upload->fh;
    my $content = do { local $/; <$fh> };
    is $content, "hoge\nbar\n";

    is $upload->size, length($content);

    my $info = $upload->info;
    isa_ok $info, 'Sledge::Request::Table';
    is_deeply \%$info, {
	'Content-Type' => 'text/plain',
	'Content-Disposition' => 'form-data; name="file1"; filename="upload.txt"',
    };

    is $upload->info('Content-Type'), 'text/plain';
    is $upload->type, 'text/plain';

    my $next = $upload->next;
    isa_ok $next, 'Sledge::Request::Upload';
    is $next->name, 'file2';

    my $match = $ENV{TMPDIR} || '/tmp/';
    like $upload->tempname, qr|$match|o;

    my $tmpfile = 't/.tmp';
    $upload->link($tmpfile);
    ok -e $tmpfile;
    is catfile($tmpfile), "hoge\nbar\n";
    unlink $tmpfile;
}

{
    ok my $upload = $r->upload('file2');
    isa_ok $upload, 'Sledge::Request::Upload';
    is $upload->name, 'file2';
    is $upload->filename, 'baz.html';
}

{
    my @upload = $r->upload;
    is @upload, 2;
    isa_ok $_, 'Sledge::Request::Upload' for @upload;
}

sub catfile {
    local $/;
    return FileHandle->new(shift)->getline;
}

