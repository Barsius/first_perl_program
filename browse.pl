#!/usr/bin/perl
#NOT WORKING!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
use strict;
use warnings FATAL => 'all';
use CGI;
use CGI::Browse;

my %cgi_vars = CGI->Vars;

my $fields = [ { name   => 'user_id', label => 'ID',
    hide => 1, sort => 0 },
    { name   => 'username',            label => 'State',
        hide => 0, sort => 1, link => 'link1', id => 0 },
    { name   => 'email',   label => 'Statehood',
        hide => 0, sort => 1 },
    { name   => 'password',          label => 'Capital',
        hide => 0, sort => 1, link => 'link2', id => 0 }
    ];

my $params = { fields   => $fields,
    sql      => "SELECT user_id, username, email, password from user",
    connect  => { db => 'perlDB', host => 'localhost', user => 'perl_user', pass => 'perlpass', port => '3306' },
    urls     => { root   => '/',
        browse => 'cgi-bin/eg/browse_tmpl.cgi',
        link1  => 'cgi-bin/eg/browse_link1.cgi?id=',
        link2  => 'cgi-bin/eg/browse_link2.cgi?id=',
        delete => 'cgi-bin/eg/browse_delete.cgi' },
    features => { delete => 'multi' } };

my $browse = CGI::Browse->new( $params );

my $html  = "Content-type: text/html\n";
$html .= "Status: 200 OK \n\n";
$html .= "<html>\n";
$html .= "<head>\n";
$html .= "  <title>CGI::Browse Module Sample Script</title>\n";
$html .= $browse->_build_styles();
$html .= "</head>\n";
$html .= "<body>\n";
$html .= $browse->build(\%cgi_vars);
$html .= "</body>\n";
$html .= "</html>\n";
# Print page
print $html;
