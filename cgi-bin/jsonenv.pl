#!/usr/bin/perl

binmode(STDOUT);


my $query = {}; 
our $dbug = $1 if ($ENV{QUERY_STRING} =~ m/dbug=(\d+)/);
if (exists $ENV{QUERY_STRING}) {
   my @params = split /\&/,$ENV{QUERY_STRING};
   foreach my $e (@params) {
      my ($p,$v) = split/=/,$e;
      $query->{$p} = $v; 
   }   
}
if ($dbug) {
   binmode(STDOUT);
   print "Content-Type: text/plain\r\n\r\n";
} 

# ---------------------------------------------------------
# CORS header
if (exists $ENV{HTTP_ORIGIN}) {
  printf "Access-Control-Allow-Origin: %s\n",$ENV{HTTP_ORIGIN};
} else {
  print "Access-Control-Allow-Origin: *\n";
}
# ---------------------------------------------------------
use if -e '/usr/local/share/perl5/cPanelUserConfig.pm', cPanelUserConfig;
use JSON qw(encode_json);
$ENV{pid} = $$;
my $jsenv = encode_json( \%ENV );

$jsenv =~ s/,/,\n/g if $dbug;

if (exists $query->{callback}) {
   print "Content-Type: text/javascript\r\n\r\n";
   printf qq'%s(%s)\n',$query->{callback},$jsenv;
} else {
   print "Content-Type: application/json\r\n\r\n";
   printf qq'%s\n',$jsenv;
}


