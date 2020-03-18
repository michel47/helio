#!/usr/bin/perl


print qq'Content-Type: text/plain\r\n\r\n';

printf "%s: OK!\n",$0;
print "\n";
printf "X_SCRIPT_NAME: %s\n",$ENV{SCRIPT_NAME};


exit $?;
1; # $Source: /my/cgi/scripts/cgitest.pl $
