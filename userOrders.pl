#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use CGI;
use DBHandler;

my $cgi = CGI->new;

my @usersWithOrders = DBHandler->getAllUsersWithOrders;

print $cgi->header, $cgi->start_html('Orders of Users'),
    $cgi->h1('User List'),
    $cgi->start_table({ border => 1 }),
    $cgi->Tr($cgi->th('UserID'), $cgi->th('Username'), $cgi->th('Product'), $cgi->th('Quantity'))
;

foreach my $userWithOrder (@usersWithOrders) {
    print $cgi->Tr($cgi->td($userWithOrder->{UserID}),
        $cgi->td($userWithOrder->{Username}),
        $cgi->td($userWithOrder->{Product}),
        $cgi->td($userWithOrder->{Quantity})
    );
}

print $cgi->end_table;
print $cgi->end_html;
