#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;
use DBHandler;
use MyUtils;

my $cgi = CGI->new;

if ($cgi->param('new_username') && $cgi->param('new_email') && $cgi->param('new_password')) {

    #HANDLE POST REQUEST TO ADD USER

    my $new_username = $cgi->param('new_username');
    my $new_email    = $cgi->param('new_email');
    my $new_password = $cgi->param('new_password');

    DBHandler->createUser($new_username, $new_email, $new_password);
} elsif ($cgi->param('id')) {

    #HANDLE DELETE REQUEST TO DELETE USER

    my $id = $cgi->param('id');
    DBHandler->deleteUser($id);
} elsif ($cgi->param('changedName') && $cgi->param('changedName') && $cgi->param('changedPassword') && $cgi->param('userId')){

    #HANDLE POST REQUEST TO UPDATE USER

    if (!MyUtils::is_valid_email(($cgi->param('changedEmail')))) {
        print $cgi->header(-status => '400 Bad Request');
        print "Invalid email address";
        exit;
    }

    DBHandler->updateUser($cgi->param('changedName'), $cgi->param('changedEmail'), $cgi->param('changedPassword'), $cgi->param('userId'));
} else {

    #HANDLE GET REQUEST TO GET ALL USERS

    my @users = DBHandler->getAllUsers;

    print $cgi->header, $cgi->start_html('Users'),
        $cgi->h1('User List'),
        $cgi->start_table({ border => 1 }),
        $cgi->Tr($cgi->th('User ID'), $cgi->th('Username'), $cgi->th('Email'), $cgi->th('Password'), $cgi->th('Delete'), $cgi->th('Edit'), $cgi->th('Orders')),
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
                -onClick => "openModal('$user->{username}', '$user->{email}', '$user->{password}', '$user->{user_id}');")),
            $cgi->td($cgi->button(-name    => 'Orders',
                -onClick => "openOrders($user->{user_id})")));
    }

    print $cgi->end_table;
}

print $cgi->end_html;