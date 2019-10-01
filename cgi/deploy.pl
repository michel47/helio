#!/usr/bin/perl

print "Content-Type: text/html\r\n\r\n";

print "<h3>deploy:</h3><pre>\n";
system "sh deploy.sh";
exit $?;

1;
