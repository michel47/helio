#!/usr/bin/perl

my $ip = $ENV{REMOTE_ADDR};

binmode(STDOUT);


our $dbug=0; $dbug = 1 if ($ENV{QUERY_STRING} =~ m/dbug=/);

if ($dbug) {
   binmode(STDOUT);
   print "Content-Type: text/html\r\n\r\n";
} 

my $query = {}; 
our $dbug = $1 if ($ENV{QUERY_STRING} =~ m/dbug=(\d+)/);
if (exists $ENV{QUERY_STRING}) {
   my @params = split /\&/,$ENV{QUERY_STRING};
   foreach my $e (@params) {
      my ($p,$v) = split/=/,$e;
      $query->{$p} = $v; 
   }   
}


print "Content-Type: text/javascript\r\n\r\n";
print "\r\n\r\n";

if (exists $query->{callback}) {
   printf qq'%s({"ip":"%s","tic":"%s","msg":"Hello!"})\n',$query->{callback},$ip,$^T;
} else {
   printf qq'{"ip":"%s","tic":"%s","msg":"Hello!"}\n',$ip,$^T;
}

if ($dbug) {
   print "/* <pre><b>Environment:</b>\n";
   foreach (sort grep /^HTTP|^SERVER|PATH_|UR[LI]|QUERY_/, keys %ENV) {
      printf "%s: %s\n",$_,$ENV{$_};
   }
   print " */\n";
}


