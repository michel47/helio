#!/usr/bin/perl

#use lib $ENV{HOME}.'/site/lib';
#use UTIL qw(get_spot);

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


my $spot = &get_spot();
print $spot,"\n";
exit $?;

sub get_spot {
   my $tic = $_[0] || $^T;
   my $time = 59 * int (($tic - 58) / 59) + int rand(59);
   my $pubip = $ENV{REMOTE_ADDR} || '0.0.0.0' ;

   my $lip = unpack'N',pack'C4',split('\.','127.0.0.1');
   my $nip = unpack'N',pack'C4',split('\.',$pubip);
   my $spot = $time ^ $nip ^ $lip;
   return $spot;
}


1; # $Source: /my/perl/scripts/spot_cgi.pl $


