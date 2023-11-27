#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;
use DBConfig;
use DBHandler;

my $cgi = CGI->new;

if ($cgi->param('new_username') && $cgi->param('new_email') && $cgi->param('new_password')) {
    my $new_username = $cgi->param('new_username');
    my $new_email    = $cgi->param('new_email');
    my $new_password = $cgi->param('new_password');

    DBHandler->createUser($new_username, $new_email, $new_password);

    print $cgi->redirect('my_page.pl');
    exit;
}

my @users = DBHandler->getAllUsers;

print $cgi->header, $cgi->start_html('User List'),
    $cgi->h1('User List'),
    $cgi->start_table({border => 1}),
    $cgi->Tr($cgi->th('User ID'), $cgi->th('Username'), $cgi->th('Email'), $cgi->th('Password'), $cgi->th('Delete')),
;

foreach my $user (@users) {
    print $cgi->Tr($cgi->td($user->{user_id}), $cgi->td($user->{username}), $cgi->td($user->{email}), $cgi->td($user->{password}), $cgi->td($cgi->button({-name =>'Delete'})));
}

print $cgi->end_table;

print $cgi->start_form(-method => 'POST', -action => 'my_page.pl'),
    $cgi->h2('Create a New User'),
    $cgi->p('Username: ', $cgi->textfield(-name => 'new_username')),
    $cgi->p('Email: ', $cgi->textfield(-name => 'new_email')),
    $cgi->p('Password: ', $cgi->textfield(-name => 'new_password')),
    $cgi->submit(-value => 'Create User'),
    $cgi->end_form;

print $cgi->end_html;