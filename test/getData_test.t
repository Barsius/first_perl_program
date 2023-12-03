#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 4;
use MyUtils;

# Test cases for your subroutines
ok( MyUtils::is_valid_email('user@example.com'), 'Valid email address' );
ok( !MyUtils::is_valid_email('invalid-email'), 'Invalid email address without @' );
ok( !MyUtils::is_valid_email('user@.com'), 'Invalid email address without domain' );
ok( !MyUtils::is_valid_email('user@com'), 'Invalid email address without dot in domain' );

done_testing();
