#!/usr/bin/perl

binmode(STDOUT);
my $ico = 'data:image/x-icon;base64,AAABAAEAEBAAAAEACABoBQAAFgAAACgAAAAQAAAAIAAAAAEACAAAAAAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAAAAPh7cADMRpgA/H9EAQCG7AD8fyQBBIrAAQCC+AEEjpQA8HLkAQiaMAD8f0gA+HeAAPyDHACcEvABAIbwARShuAEEisQBAIL8AQCG0AEEjpgBCJJsAQiWQAD8f0wA+HeEAQyaFACkLkAA/IMgAPx7WAEMliABAIb0AQSKyAEAgwAD+/v4AQSOnAEAhtQBBIqoAQiScAEIlkQA+HeIAQyaGADIQxQA/HtcAPx/MAEAgwQBAIbYAQSKrAEIknQBCJZIAQiOgAEMmhwCPgdcAPx/NAC4buABAIMIAQSK0AEEirABBI6EAQyaIAEMliwA/H84AW0a6AEAgwwBAIbgAQSKtAEEjogBCI6IA/f38AEIklwBCJYwAQyWMAP///wBAIMQAQCG5ADYWpwD+/f0AQiSYAD4e2wBDJY0APx/IAEEirwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABY7AAAAAAAAAAAAAAAAJ0wwCh0QAAAAAAAAAAAAJzklRDBFMjoAAAAAAAAAJ0AiQS9EMEY6GQAAAAAAJyMfOBRBJUQwRjIoAAAAJywELRECMzMaRDBOKDEAJydIEg8tR0tDRxVEMEYxMScnJ0gSBDNLITNCL0wmMTEnJycFSCAJIUtKFEIlRDExJycnPE9INSEhPSQIQhUxMScnJxc8BUdHR0dQLhQxMTEnJwEqCzwzIUczE1AkCDExJycYTSoLNCkOB0k3BiQxMScnJwxNHAs0Gz4PPzdQMTEnJycnDE0cCzQbPh4/NzExACcnJycMTRwDKw02Hi4xAP5/AAD4HwAA8A8AAOAHAADAAwAAgAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIABAAA=';

if ($ENV{REQUEST_METHOD} eq 'OPTIONS') { # pre-flight :
   print "Status: 204 No Content\n";
   print "Access-Control-Allow-Credentials: true\n";
   print "Access-Control-Allowed-Methods: GET, OPTIONS\n";
   print "Access-Control-Allow-Headers: Authorization, Content-Type\n";
   print "Content-Type: text/javascript\r\n\r\n";
   print "\r\n";
   print "console.log('Hi OPTION (pre-flight) !')\n";

} elsif (exists $ENV{HTTP_ORIGIN}) { # Allowed Origin :
   printf "%s 200 OK\r\n",($nph)?'HTTP/1.1':'Status:';
   printf "Access-Control-Allow-Origin: %s\n",$ENV{HTTP_ORIGIN};
   print "Access-Control-Allow-Credentials: true\n";
   print "Content-Type: text/javascript\r\n";
   print "\r\n";
   printf "console.log('favicon: Hello ORIGIN: %s')\n",$ENV{HTTP_ORIGIN};
} elsif (exists $ENV{HTTP_REFERER}) {
   printf "%s 200 OK\r\n",($nph)?'HTTP/1.1':'Status:';
   printf "Access-Control-Allow-Origin: %s\n",$ENV{HTTP_REFERER};
   print "Content-Type: text/javascript\r\n";
   print "\r\n";
   printf "console.log('favicon: Hello REFERER: %s')\n",$ENV{HTTP_REFERER};

} elsif (exists $ENV{HTTP_AUTHORIZATION}) { # Same Origin Only
   printf "%s 200 OK\r\n",($nph)?'HTTP/1.1':'Status:';
   printf "Access-Control-Allow-Origin: %s\n",$ENV{HTTP_HOST};
   print "Content-Type: text/javascript\r\n";
   print "\r\n";
   printf "console.log('favicon: Hello Auth: %s')\n",$ENV{HTTP_AUTHORIZATION};

} elsif (1) {
   printf "%s 401 Unauthenticated\r\n",($nph)?'HTTP/1.1':'Status:';
   print "Access-Control-Allow-Credentials: true\n";
   print "Access-Control-Allowed-Methods: GET, OPTIONS\n";
   print "Access-Control-Allow-Headers: Authorization, Content-Type\n";
   print qq'WWW-Authenticate: Basic realm="CORS"\r\n';
   print "Content-Type: text/javascript\r\n\r\n";
   print "\r\n";
   print "console.log('Hi 401!')\n";
} else { # unknow origin
   printf "%s 204 No Content; Method Not Allowed w/o CORS\r\n",($nph)?'HTTP/1.1':'Status:';
   print "Access-Control-Allowed-Methods: GET, OPTIONS\n";
   print "Access-Control-Allow-Headers: Authorization, Content-Type\n";
   printf "Access-Control-Allow-Origin: %s\n",$ENV{HTTP_HOST};
   print "Content-Type: text/javascript\r\n";
   print "\r\n";
   print "console.log('favicon: unknow origin')\n";
   exit;

}
printf <<EOT;
 let loc = window.parent.location;
 let origin = document.location.origin;
EOT

use Digest::MD5 qw(); # md5 : 128-bit;
my $origin = $ENV{HTTP_ORIGIN};
my $hash = substr(Digest::MD5::md5_hex($origin),0,16);

my $grurl='http://www.gravatar.com/avatar/%s?s=64&d=wavatar&f=y';
my $boturl='https://cdn.statically.io/img/robohash.org/set_set1/bgset_bg0/size_32x32/ignoreext_false/%s.png';
my $evurl='https://cdn.statically.io/img/evatar.io/%s.png';

my $grav = sprintf $grurl,$hash;
my $bot = sprintf $boturl,$hash;
my $evi = sprintf $evurl,$hash;

printf qq{document.write('<link id=favicon href="%s" rel="icon" type="image/x-icon" title="'+origin+'"/>');\n},$evi;
printf "// tics: %s\n",$^T;
use YAML::Syck qw(Dump);
my $envp = Dump(\%ENV); $envp =~ s,\n,\n// ,g;
printf qq'// --- # ENV %s...\n',$envp;


exit $?;

1;

