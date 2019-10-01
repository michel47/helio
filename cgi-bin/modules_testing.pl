#!/usr/bin/perl -w 

our $helio = undef;
our $ocean = 1 if (exists $ENV{USER} && $ENV{USER} eq 'iggy');
if (exists $ENV{SHLVL}) {
 $ENV{DOCUMENT_ROOT} = $ENV{HOME}.'/odrive/tommy/public_html';
}

binmode(STDOUT);
my $CRLF = pack'H*','0D0A';
my $nph = 0; # NPH script (non-parsed-header)
printf "HTTP 200 OK\n" if $nph;
print "Content-Type: text/html\r\n";
print $CRLF x 1;
#print "\015\012";


if (-e '/usr/local/share/perl5/cPanelUserConfig.pm') {
  use cPanelUserConfig;
  $helio++;
}
use YAML::Syck qw(Dump DumpFile LoadFile);
use Time::Local qw(timelocal);
use Math::BigInt;
use Digest;
use Digest::SHA1 qw//;
use MIME::Base64 qw/encode_base64/;
use Math::Prime::Util qw(irand64 urandomm csrand random_strong_prime entropy_bytes);
use Encode::Base58::BigInt qw();
use Digest::JHash;
use Digest::MurmurHash;
use GD qw();
use Math::Random::Secure qw(srand rand irand);



# -----------------------------------------------------
print "<!DOCTYPE html>\n";
print "<pre>";
printf "Hello World (%s)\n",&hdate($^T);

  my $seed = srand();
printf "seed: %s\n",unpack'H*',$seed;
my $rand = irand();
printf "rand: %x\n",$rand;

printf "Murmur (Austin Appleby's): %s\n",&h32_mmhash($seed);
printf "Bob Jenkin's : %s\n",&h32_jhash($rand);
my $x = Math::BigInt->from_bytes("\xf3\x6b");  # $x = 62315
printf "x: %s\n",$x;

printf "base58 : %s\n",&encode_base58(pack 'N',&h32_jhash('abc'));

if (0) {
   my $file = $ENV{DOCUMENT_ROOT}.'/img/fff.png';
   my $image = &stamp_img($file,123,'iggy');
   my $img64 = &encode_base64($image,'');
   # DATA URI see [1](https://en.wikipedia.org/wiki/Data_URI_scheme)
   printf "<img src=data:image/png;base64,%s>\nbase64:%s...\n",$img64,substr($img64,0,80);

}

if (0 && $helio) {
   # ----------------------------------------------------
   $ENV{IPFS_PATH} = '/home/michelc/.ipfs';
   system "/home/michelc/bin/ipfs id";
   system "/home/michelc/bin/ipfs diag sys";
   # ----------------------------------------------------
}

printf "HOSTNAME: %s\n",$ENV{HOSTNAME} if (exists $ENV{HOSTNAME});
printf "USER = '%s'\n",$ENV{USER} if (exists $ENV{USER});
#printf "%s.\n",Dump(\%INC);

if ($helio) {
system "ps -ux";
} elsif ($ocean) {
  print "local !\n";
} else {
system "ps -u";
}
print "done !\n";
print "</pre>";
exit $?;

# -----------------------------------------------------
sub stamp_img {
   my ($file,$tic,$sign) = @_;
   my $string = 'This is a test';
   use GD;
   GD::Image->trueColor(1);
   my $image = GD::Image->new($file);
   my ($width, $height) = $image->getBounds();
   my $color = $image->colorAllocate(254,254,255);
   print "$width $height\n";
   my $font = $ENV{DOCUMENT_ROOT}.'/fonts/trebuc.ttf';
   my $point_size = 14;
   my $angle = 0;
   my ($x,$y) = ($width/2-54,$height/2);
   $image->stringFT($color, $font, $point_size, $angle, $x, $y, $string);

   return $image->png;

}
# -----------------------------------------------------
sub encode_base58 {
  use Math::BigInt;
  use Encode::Base58::BigInt qw();
  my $bin = join'',@_;
  my $bint = Math::BigInt->from_bytes($bin);
  my $h58 = Encode::Base58::BigInt::encode_base58($bint);
  $h58 =~ tr/a-km-zA-HJ-NP-Z/A-HJ-NP-Za-km-z/; # TBD refactor with basen
  return $h58;
  
}
# -----------------------------------------------------
sub base36 { # letters and numbers
  use integer;
  my ($n) = @_;
  my $e = '';
  return('0') if $n == 0;
  while ( $n ) {
    my $c = $n % 36;
    $e .=  ($c<=9)? $c : chr(0x37 + $c); # 0x37: upercase, 0x57: lowercase
    $n = int $n / 36;
  }
  return scalar reverse $e;
}
# -----------------------------------------------------
sub digest {
 my $alg = shift;
 my $msg = undef;
 #use Digest qw();
 if ($alg eq 'GIT') {
   $msg = Digest->new('SHA1') or die $!;
   $msg->add(sprintf "blob %u\0",length($_[0]));
 } else {
   $msg = Digest->new($alg) or die $!;
 }
 $msg->add($_[0]);
 my $digest = lc( $msg->hexdigest() );
 return $digest; #hex form !
}
# -----------------------------------------------------
sub h32_mmhash { #  Austin Appleby's hash
   use Digest::MurmurHash;
   my $digest = Digest::MurmurHash::murmur_hash(join'',@_);
   return $digest;
}
sub h32_jhash { # Bob Jenkins' hash
 use Digest::JHash;
 my $digest = Digest::JHash::jhash(join'',@_);
 return $digest;
}
# -----------------------------------------------------
sub hdate { # return HTTP date (RFC-1123, RFC-2822) 
  my $DoW = [qw( Sun Mon Tue Wed Thu Fri Sat )];
  my $MoY = [qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec )];
  my ($sec,$min,$hour,$mday,$mon,$yy,$wday) = (gmtime($_[0]))[0..6];
  my ($yr4,$yr2) =($yy+1900,$yy%100);
  # Mon, 01 Jan 2010 00:00:00 GMT

  my $date = sprintf '%3s, %02d %3s %04u %02u:%02u:%02u GMT',
             $DoW->[$wday],$mday,$MoY->[$mon],$yr4, $hour,$min,$sec;
  return $date;
}
# -----------------------------------------------------
1; # vim: ff=unix ts=2 sw=3 et ai




