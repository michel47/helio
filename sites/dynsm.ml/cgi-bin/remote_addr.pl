#!/usr/bin/perl

binmode(STDOUT);
# ---------------------------------------------------------
# CORS header
if (exists $ENV{HTTP_ORIGIN}) {
  printf "Access-Control-Allow-Origin: %s\n",$ENV{HTTP_ORIGIN};
} else {
  print "Access-Control-Allow-Origin: *\n";
}
# ---------------------------------------------------------
print "Content-Type: text/plain\r\n\r\n";

my $ip = $ENV{REMOTE_ADDR};
print $ip,"\n";
exit $?;
1; # $Source /my/perl/scripts/remote_addr.pl $