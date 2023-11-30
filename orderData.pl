#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;
use DBHandler;

my $cgi = CGI->new;

if ($cgi->param('userId')) {
    my @orders = DBHandler->getOrdersByUserId($cgi->param('userId'));

    print $cgi->header, $cgi->start_html('Orders'),
        $cgi->h1('Order List'),
        $cgi->start_table({ border => 1 }),
        $cgi->Tr($cgi->th('OrderId'), $cgi->th('Product'), $cgi->th('Order Date'), $cgi->th('Quantity'))
    ;

    foreach my $order (@orders) {
        print $cgi->Tr($cgi->td($order->{order_id}),
            $cgi->td($order->{product_name}),
            $cgi->td($order->{order_date}),
            $cgi->td($order->{quantity}));
    }
}
