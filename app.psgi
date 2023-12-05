use strict;
use warnings;
use Plack::Builder;
use Plack::App::CGIBin;
use Plack::Middleware::Static;
use Plack::Middleware::Session;
use MIME::Base64;
use FindBin;

use lib "$FindBin::Bin/lib";

my $test_result = system("prove -l test");
if ($test_result != 0) {
    die "Tests failed. Server not started.\n";
}

my $realm = 'Restricted Area';
my $username = 'your_username';
my $password = 'your_password';

my $authenticator = sub {
    my ($username_entered, $password_entered) = @_;
    return $username_entered eq $username && $password_entered eq $password;
};

my $app_cgi = Plack::App::CGIBin->new(root => './')->to_app;

my $app_static = Plack::Middleware::Static->new(
    path => qr{^/(static|images|css|js)/},
    root => './',
)->wrap($app_cgi);

builder {
    enable 'Lint';
    enable 'Session';
    enable sub {
        my $app = shift;
        return sub {
            my $env = shift;

            return $app->($env) if $env->{PATH_INFO} eq '/authorization.pl';

            if ($env->{HTTP_AUTHORIZATION}) {
                my ($type, $credentials) = split /\s+/, $env->{HTTP_AUTHORIZATION}, 2;
                if ($type eq 'Basic') {
                    my ($user, $pass) = split /:/, decode_base64($credentials), 2;
                    return $app->($env) if $authenticator->($user, $pass);
                }
            } elsif ($env->{HTTP_COOKIE} && $env->{HTTP_COOKIE} =~ /Authorization=([^;]+)/) {
                my $cookie_value = $1;
                my ($user, $pass) = split /:/, decode_base64($cookie_value), 2;
                return $app->($env) if $authenticator->($user, $pass);
            }

            # Redirect to login page
            return [ 302, [ 'Location' => '/authorization.pl' ], [] ];
        };
    };
    $app_static;
};
