#!/usr/bin/perl


print qq'Content-Type: text/plain\r\n\r\n';

printf "%s: OK!\n",$0;
print "\n";
printf "Hello, World!\n";


exit $?;
1; # $Source: /my/cgi/scripts/hello.pl $
