package DBConfig;

use strict;
use warnings;

sub config {
    return {
        database => 'perlDB',
        host     => 'localhost',
        port     => '3306',
        user     => 'perl_user',
        password => 'perlpass',
    };
}

1;