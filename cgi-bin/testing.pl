#!/usr/bin/perl

printf "Access-Control-Allow-Headers: %\n",'content-type, application/x-www-form-urlencoded';
if (exists $ENV{HTTP_ORIGIN} && $ENV{HTTP_ORIGIN} ne '') {
  printf "Access-Control-Allow-Origin: %s\n",$ENV{HTTP_ORIGIN};
} else {
  print "Access-Control-Allow-Origin: *\n";
}
print "Content-Type: text/html; charset=utf-8\r\n\r\n";

if (0) {
   print "<pre>"; # display environment ...
   foreach (sort grep /(SCRIPT|PATH_)/, keys %ENV) {
      printf "%s: %s\n",$_,$ENV{$_};
   }
   print "</pre>\n";
}
if (exists $ENV{PATH_INFO}) {
   #printf qq'INITIAL_PATH_INFO="%s";<br>\n',$ENV{PATH_INFO};
   
   if ($ENV{PATH_INFO} =~  m'^/([^/]*)/cgi-bin') { # proxying dyn℠ site
     my $p0 = length($&)+1;
     my $p1 = index $ENV{PATH_INFO},'/',$p0+1;
        $p1 = length$ENV{PATH_INFO} if ($p1 < 0);
     $ENV{SCRIPT_NAME} = '../sites'.substr($ENV{PATH_INFO},0,$p1);
     $ENV{PATH_INFO} = substr($ENV{PATH_INFO},$p1);
   } else {
      my $p = index $ENV{PATH_INFO},'/',1;
      $p = length$ENV{PATH_INFO} if ($p < 0);
      $ENV{SCRIPT_NAME} = '.'. substr($ENV{PATH_INFO},0,$p,'');
      #$ENV{SCRIPT_NAME} =~ s,testing.pl,$SCRIPT,;
   }
   printf qq'SCRIPT_NAME="%s";<br>\n',$ENV{SCRIPT_NAME};
   printf qq'PATH_INFO="%s";<br>\n',$ENV{PATH_INFO};

   $ENV{PATH_TRANSLATED} = $ENV{DOCUMENT_ROOT}.$ENV{PATH_INFO};
   if ($ENV{PATH_INFO} eq '') {
     $ENV{PATH_INFO} = undef;
     delete $ENV{PATH_INFO};
   } else {
     printf qq'PATH_INFO="%s";<br>\n',$ENV{PATH_INFO};
   }
   print "$^X <a href=$ENV{SCRIPT_NAME}>$ENV{SCRIPT_NAME}</a><br>\n<pre><code>"; # /!\\ INSECURE
   my $status = system qq'$^X "$ENV{SCRIPT_NAME}" 2>&1'; # /!\ exploitable
   print "</code></pre><br/>.<br/>\n";
   printf "<pre>status: %s</pre>\n",$status;
   if ($status != 0 && ! -x $ENV{SCRIPT_NAME}) {
     chmod 0744, $ENV{SCRIPT_NAME};
   }
   exit;
}

if (-x 'modules_testing.pl') {
   print "$^X modules_testing.pl\n";
   system "$^X modules_testing.pl 2>&1";
}

exit $?;

1;
