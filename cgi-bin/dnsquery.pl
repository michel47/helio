#!/usr/bin/perl


my $query = {}; 
our $dbug = $1 if ($ENV{QUERY_STRING} =~ m/dbug=(\d+)/);
if (exists $ENV{QUERY_STRING}) {
   my @params = split /\&/,$ENV{QUERY_STRING};
   foreach my $e (@params) {
      my ($p,$v) = split/=/,$e;
      $v =~ s/%(..)/chr(hex($1))/eg; # unhtml-ize (urldecoded)
      $query->{$p} = $v; 
   }   
}
if ($dbug) {
   use YAML::Syck qw(Dump);
   binmode(STDOUT);
   print "Content-Type: text/plain\r\n\r\n";

   printf "X-INC: %s\n",join',',@INC;
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
use lib '../../../repositories';
use Brewed::DNS qw(get_rrecord);
# A : 1, NS : 2, MD : 3, MF : 4, CNAME : 5, SOA : 6,
# MB : 7, MG : 8, MR : 9, NULL : 10, WKS : 11,
# PTR : 12, HINFO : 13, MINFO : 14, MX : 15, TXT : 16, RP : 17,
# AFSDB : 18, AAAA : 28, SRV : 33, SSHFP : 44, RRSIG : 46, AXFR : 252,
# ANY : 255, URI : 256, CAA : 257

use JSON qw(decode_json encode_json);

my $post;
{
local $/ = undef; # /!\ destroy DNS read ...
   $post = <STDIN>;
}
#printf "DBUG: [%s]\n",join"\n",Dump(&get_rrecord('exemple.com','A'));
#printf "DBUG: query=[%s]\n",join"\n",Dump($query); exit;
#printf "X-CONTENT_TYPE: %s\n",$ENV{CONTENT_TYPE};
printf "X-post: %s\n",$post;

if ($ENV{CONTENT_TYPE} eq 'application/x-www-form-urlencoded') {
#  print "Content-Type: text/plain; charset=utf-8\r\n\r\n";
#  printf "post: %s\n",$post if $dbug;
  my @params = split /\&/,$post;
   foreach my $e (@params) {
      my ($p,$v) = split/=/,$e;
#     printf "%s: %s\n",$p,$v;
      $v =~ s/%(..)/chr(hex($1))/eg; # unhtml-ize (urldecoded)
      $query->{$p} = $v; 
  }   
#  printf "query: [%s]\n",Dump($query) if $dbug;
}

if ($query->{echo}) {
   print "Content-Type: text/plain\r\n\r\n";
   print $post;
   exit;
} else {
    my $jspost;
    if ($query->{json}) {
#     printf "json: %s\n",$query->{json} if $dbug;
      $jspost = decode_json($query->{json});
    } elsif ($ENV{CONTENT_TYPE} eq 'application/json') {
      $jspost = decode_json($post);
    }
   printf "jspost: %s\n",Dump($jspost) if $dbug;
    # only Domain and Type keys are copied from the json object
    $query->{domain} = $jspost->{Domain} if exists $jspost->{Domain};
    $query->{type} = $jspost->{Type} if exists $jspost->{Type};
    printf "X-query: %s %s\n",$query->{domain},$query->{type};
}


my ($domain,$type) = ($query->{domain},$query->{type});
my $rr = &get_rrecord($domain,$type);
#printf "--- # rr %s...\n",Dump($rr) if ($ENV{TERM} =~ /xterm/);

my $resp;
if (exists $rr->[0]{error}) {
 $resp = { query => $query, status => 'error', errormsg => $rr->[0]{error}, rr => $rr };
} else {
 $resp = { query => $query, status => 'ok',n => scalar(@{$rr}), rr => $rr };
}
printf "--- # resp %s...\n",Dump($espr) if ($ENV{TERM} =~ /xterm/);

my $jsresp = encode_json( $resp );

$jsresp =~ s/,/,\n/g if $dbug;

if (exists $query->{callback}) { # /!\ callback can be tainted
   print "Content-Type: text/javascript\r\n\r\n";
   printf qq'%s(%s)\n',$query->{callback},$jsresp;
} else {
   print "Content-Type: application/json\r\n\r\n";
   printf qq'%s\n',$jsresp;
}

#printf "<pre>env: %s...\n",Dump(\%ENV) if $dbug;

1;

