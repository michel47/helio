#!/usr/bin/perl

print "Content-Type: text/html\r\n";
print "\r\n";
$ENV{PATH_INFO} =~ s,/bin,./../bin,;
$ENV{PATH_INFO} =~ s,/sec,./../.sec,;
#$ENV{PATH_INFO} =~ s,/etc,./etc,;
my $file = '.'.$ENV{PATH_INFO};
$file = '..'.$ENV{PATH_INFO} unless -f $file; # /!\ caution

# Make sure if is run by the right persons ...
if ($ENV{REMOTE_ADDR} !~ m'194\.230\.158\.' && $ENV{REMOTE_ADDR} !~ m'178\.123' && $ENV{REMOTE_ADDR} ne '127.0.0.1') {

   printf "<p>your ip address (%s) has been logged for forensic analysis\n</p>",
          $ENV{REMOTE_ADDR};
} elsif (-r $file) {
printf "<pre>cat &gt; %s &lt;&lt;EOF\n<code>",$file;
exit unless -r $file;
local *F; open F,'<',$file;
while (<F>) {
  s/</\&lt;/g;
  if (m,(/ip[fn]s/\w+),) {
   my $ipath = $1;
   s,$ipath,<a href=http://ipfs.gc-bank.org$ipath>$ipath</a>,;
  }
  print;
}
close F;
print "</code>EOF</pre>\n";
} else {
  print "! -r $file\n";
}

exit $?;

1;

