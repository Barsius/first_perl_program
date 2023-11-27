#!/usr/bin/perl
use strict;
use warnings;

print "Content-type: text/html\n\n";
print "<html><head><title>Dynamic page</title></head><body>";

my $name = $ENV{'QUERY_STRING'} || 'Guest';

print "<h1>Hello, $name!</h1>";
print "<p>Local Time: " . localtime() . "</p>";

print "</body></html>";

