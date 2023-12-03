use strict;
use warnings;
use Plack::Builder;
use Plack::App::CGIBin;
use Plack::Middleware::Static;
use FindBin;

use lib "$FindBin::Bin/lib";

my $test_result = system("prove -l test");
if ($test_result != 0) {
    die "Tests failed. Server not started.\n";
}

my $app_cgi = Plack::App::CGIBin->new(root => './')->to_app;

my $app_static = Plack::Middleware::Static->new(
    path => qr{^/(static|images|css|js)/},
    root => './',
)->wrap($app_cgi);

builder {
    enable 'Lint';
    $app_static;
};