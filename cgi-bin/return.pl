#!/usr/bin/perl

# simply return the posted json object ...

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
use JSON qw(encode_json);

local $/ = undef;
my $post = <STDIN>;

my %resp = ( post => $post, query => \%query, env => \%ENV );

my $jsresp = encode_json( \%resp );

$jsresp =~ s/,/,\n/g if $dbug;

if (exists $query->{callback}) { # /!\ callback can be tainted
   print "Content-Type: text/javascript\r\n\r\n";
   printf qq'%s(%s)\n',$query->{callback},$jsresp;
} else {
   print "Content-Type: application/json\r\n\r\n";
   printf qq'%s\n',$jsresp;
}


