package MyUtils;
use strict;
use warnings FATAL => 'all';

sub is_valid_email {
    my ($email) = @_;
    return $email =~ /^[^\s\@]+?\@[^\s\@]+\.[^\s\@]+$/;
}

1;