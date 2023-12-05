#!/usr/bin/env perl

use strict;
use warnings;
use CGI;
use MIME::Base64;

my $cgi = CGI->new;

my $expected_username = 'your_username';
my $expected_password = 'your_password';

if ($cgi->param('login') && $cgi->param('password')) {
    my $entered_username = $cgi->param('login');
    my $entered_password = $cgi->param('password');

    if ($entered_username eq $expected_username && $entered_password eq $expected_password) {
        my $authorization_token = MIME::Base64::encode_base64("$expected_username:$expected_password", '');
        print $cgi->redirect(-uri => '/static/new.html', -status => 302, -cookie => [$cgi->cookie(-name => 'Authorization', -value => $authorization_token)]);
    } else {
        print $cgi->header(-status => '401 Unauthorized', -WWW_Authenticate => 'Basic realm="Restricted Area"', -type => 'text/html');
        print "Authorization Required";
    }
} else {
    print $cgi->header(-type => 'text/html');
    print <<HTML;
<html>
<head><title>Login</title></head>
<body>
<form action="/authorization.pl" method="post">
    <label for="login">Username:</label>
    <input type="text" id="login" name="login" required><br>
    <label for="password">Password:</label>
    <input type="password" id="password" name="password" required><br>
    <input type="submit" value="Login">
</form>
</body>
</html>
HTML
}
