#!/usr/bin/perl

use if -e '/usr/local/share/perl5/cPanelUserConfig.pm', cPanelUserConfig;

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


binmode(STDOUT);
# ---------------------------------------------------------
# CORS header
if (exists $ENV{HTTP_ORIGIN}) {
  printf "Access-Control-Allow-Origin: %s\n",$ENV{HTTP_ORIGIN};
} else {
  print "Access-Control-Allow-Origin: *\n";
}
# ---------------------------------------------------------


if ($query->{json}) {
   print "Content-Type: application/json\r\n\r\n";
   printf qq'{"tic":%s,"nounce":%s,"dotip":"%s","pubip":"%s","seed":f%08x,"salt":%s,"spot":%s}\n',&get_spot($^T,$ENV{HTTP_HOST}||'dynsm.ml');
} else {
   print "Content-Type: text/plain\r\n\r\n";
   my $spot = &get_spot($^T,$ENV{HTTP_HOST}||'dynsm.ml');
   print $spot,"\n";
}
exit $?;

# -----------------------------------------------------------------------
sub get_spot {
   my $tic = shift || $^T;
   my $nonce;
   if (@_) {
     use Digest::MurmurHash qw();
     $nonce = Digest::MurmurHash::murmur_hash(join'',@_);
   } else {
     $nonce = 0xA5A5_5A5A;
   }
   my $dotip = &get_localip;
   my $pubip = $ENV{REMOTE_ADDR} || '127.0.0.1';
   my $lip = unpack'N',pack'C4',split('\.',$dotip);
   my $nip = unpack'N',pack'C4',split('\.',$pubip);
   my $seed = srand($nip);
   my $salt = int rand(59);
   if ($dbug) { 
      print "Content-Type: text/plain\r\n\r\n";
      printf "nonce: f%08x\n",$nonce;
      printf "dotip: %s\n",$dotip;
      printf "pubip: %s\n",$pubip;
      printf "seed: f%08x\n",$seed;
      printf "salt: %s\n",$salt;
   }
   my $time = 59 * int (($tic - 58) / 59) + $salt;
   my $spot = $time ^ $nip ^ $lip ^ $nonce;
   if (wantarray) {
     return ($tic,$nounce,$dotip,%pubip,$seed,$salt,$spot);
   } else {
     return $spot;
   }
}
# -----------------------------------------------------------------------
sub get_localip {
    use IO::Socket::INET qw();
    # making a connectionto a.root-servers.net

    # A side-effect of making a socket connection is that our IP address
    # is available from the 'sockhost' method
    my $socket = IO::Socket::INET->new(
        Proto       => 'udp',
        PeerAddr    => '198.41.0.4', # a.root-servers.net
        PeerPort    => '53', # DNS
    );
    return '0.0.0.0' unless $socket;
    my $local_ip = $socket->sockhost;

    return $local_ip;
}
# -----------------------------------------------------------------------

1; # $Source: /my/perl/scripts/spot_cgi.pl $


