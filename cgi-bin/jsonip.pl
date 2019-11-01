#!/usr/bin/perl

my $ip = $ENV{REMOTE_ADDR};

binmode(STDOUT);
use if -e '/usr/local/share/perl5/cPanelUserConfig.pm', cPanelUserConfig;


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
my $msg = "Hello, World!";

if (exists $query->{callback}) {
   print "Content-Type: text/javascript\r\n\r\n";
   printf qq'%s({"ip":"%s","tic":"%s","msg":"%s"})\n',$query->{callback},$ip,$^T,$msg;
} else {
   print "Content-Type: application/json\r\n\r\n";
   printf qq'{"ip":"%s","tic":"%s","msg":"%s"}\n',$ip,$^T,$msg;
}

if ($dbug) {
   print "/* <pre><b>Environment:</b>\n";
   foreach (sort grep /^HTTP|^SERVER|PATH_|UR[LI]|QUERY_/, keys %ENV) {
      printf "%s: %s\n",$_,$ENV{$_};
   }
   print " */\n";
}


