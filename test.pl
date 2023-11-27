#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use DBI;
use DBHandler;

my %users = DBHandler->getAllUsers;
print %users;