#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use Dancer;

get '/dancer' => sub {
    "Hello";
};

start;
