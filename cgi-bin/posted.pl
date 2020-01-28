#!/usr/bin/perl

printf "X-From: %s %s\r\n",'bot',&mdate($^T);
printf "Date: %s\r\n",&hdate($^T);
print "Content-Type: text/plain\r\n";
print "Status: 200 OK\r\n";
print "\r\n";
local $/ = undef;
my $buf = <STDIN>;

#rintf "SERVER_ADMIN: %s\n",$ENV{SERVER_ADMIN};
printf "USER: %s\n",$ENV{USER} if ($ENV{USER});


foreach my $k (sort keys %ENV) {
 printf "X-%s: %s\n",$k,$ENV{$k};

}

my $auth;
if (exists $ENV{HTTP_AUTHORIZATION}) {
  my $a64 = $1 if ($ENV{HTTP_AUTHORIZATION} =~ m/Basic\s+(.*)/);
  use MIME::Base64 qw(encode_base64 decode_base64);
  $auth = decode_base64($a64);
# printf "X-auth: %s\n", $auth;
}
my ($user,$pass) = split':',$auth;

my ($name, $pass, $uid, $gid, $quota, $comment, $gcos, $dir, $shell, $expire) =getpwuid($<);
my $ruser = $user || $ENV{REMOTE_USER} || 'sybil';

printf "From %s %s\n",$name,&mdate($^T);
printf "From: %s\n",$ruser;
printf "Subject: stdin (POST content)\n",$user;

print "\n\n";
print "$buf.\n";

exit $?;

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
sub mdate { # return date for "From line"
  my $DoW = [qw/Sun Mon Tue Wed Thu Fri Sat/];
  my $MoY = [qw/Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec/];
  # From myself Thu Sep 17 08:13     2009
  my $tic = int ($_[0]);
  my $ms = ($_[0] - $tic) * 1000;
     $ms = ($ms) ? sprintf('.%04u',$ms) : '';
  my ($sec,$min,$hour,$mday,$mon,$yy,$wday) = (gmtime($tic))[0..6];
  my ($yr4,$yr2) =($yy+1900,$yy%100);
  my $date = sprintf '%3s %3s %2u %-2u:%02u:%02u%s %04u GMT',
             $DoW->[$wday],$MoY->[$mon],$mday,$hour,$min,$sec,$ms,
             $yr4;
  return $date;
}

1;
