#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;
use DBHandler;

my $cgi = CGI->new;

if ($cgi->param('new_username') && $cgi->param('new_email') && $cgi->param('new_password')) {
    my $new_username = $cgi->param('new_username');
    my $new_email    = $cgi->param('new_email');
    my $new_password = $cgi->param('new_password');

    DBHandler->createUser($new_username, $new_email, $new_password);

    print $cgi->redirect('static/new.html');
    #print $cgi->header('text/html'),
    #    "<script>window.location.reload();</script>";
    exit;
} elsif ($cgi->param('id')) {
    my $id = $cgi->param('id');
    DBHandler->deleteUser($id);
} elsif ($cgi->param('changedName') && $cgi->param('changedName') && $cgi->param('changedPassword') && $cgi->param('userId')){
    DBHandler->updateUser($cgi->param('changedName'), $cgi->param('changedEmail'), $cgi->param('changedPassword'), $cgi->param('userId'));
    print $cgi->redirect('static/new.html');
} else {

    my @users = DBHandler->getAllUsers;

    print $cgi->header, $cgi->start_html('Users'),
        $cgi->h1('User List'),
        $cgi->start_table({ border => 1 }),
        $cgi->Tr($cgi->th('User ID'), $cgi->th('Username'), $cgi->th('Email'), $cgi->th('Password'), $cgi->th('Delete'), $cgi->th('Edit')),
    ;

    foreach my $user (@users) {
        print $cgi->Tr($cgi->td($user->{user_id}),
            $cgi->td($user->{username}),
            $cgi->td($user->{email}),
            $cgi->td($user->{password}),
            $cgi->td($cgi->button(
                -name    => 'Delete',
                -onClick => "deleteUser($user->{user_id});")),
            $cgi->td($cgi->button(-name    => 'Edit',
                -onClick => "openModal('$user->{username}', '$user->{email}', '$user->{password}', '$user->{user_id}');")));
    }

    print $cgi->end_table;
}

print $cgi->end_html;