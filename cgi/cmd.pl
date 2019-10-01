
my $home = "/home/michelc";
chdir $home;
system "ls -l accessr-logs";
system "ls -l /etc/apache2/logs/access_log /etc/apache2/logs/error_log";
print ".\n";
print "access_log\n";
system "tail /etc/apache2/logs/access_log";

printf "error_log\n";
system "tail /etc/apache2/logs/error_log";
exit $?;
