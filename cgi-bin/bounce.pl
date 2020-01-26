#!/usr/bin/perl

# This script redirect to a mapped URL when clicking on a legal form !


use if -e '/usr/local/share/perl5/cPanelUserConfig.pm', cPanelUserConfig;

use Crypt::Digest::SHAKE;

use YAML::Syck qw(Dump LoadFile);
our $dbug=1 if (exists $ENV{QUERY_STRING} && $ENV{QUERY_STRING} =~ /\&dbug=[12]/);

# spot !
my $tic = 59 * int (time / 59);
my $ip = $ENV{REMOTE_ADDR} || '0.0.0.0';
my $chart = 'https://chart.googleapis.com/chart?cht=qr&choe=UTF-8&chld=H&chs=240&chl=';


local $/ = undef;
my $buf = <STDIN>; # grap posted data ...
$buf =~ s/%([0-9a-f]{2})/pack('C',hex($1))/egi; # un-html-ize
my $param = {};
my @pairs = split/\&/,$buf;
foreach my $kp (@pairs) {
  my ($name,$value) = split/=/,$kp;
  $value =~ s/\+/ /g;
  $value =~ s/%2B/\+/g;
  $param->{$name}=$value;
}
my $query = $ENV{QUERY_STRING};
my @params = split /\&/,$query;
foreach my $e (@params) {
  my ($p,$v) = split/=/,$e;
  $param->{$p} = $v;
}



if ($dbug) {
  print "Content-Type: text/plain\r\n";
  print "\r\n";
  printf "param: %s...\n",Dump($param);
  printf "env: %s...\n",Dump(\%ENV);
}

my $lang = $param->{'lang'} || 'en';
printf "Lang: %s\n",$lang;


# ----------------------------------------------------------------------------------------
# REGISTER :
#
# slink: link to protect
# desc: description
# owner: person who created the link
#
if (defined $param->{slink}) {
  my $slink = $param->{slink};
  my $desc = $param->{desc};
     $desc =~ s/"/%22/g;
  my $owner = $param->{owner};
     $owner =~ s/"/%22/g;
  my $udesc =$desc; $udesc =~ s/\s+/-/g;

  printf "X-slink: %s\n",$slink;
  my $shash = &shake(16,$slink.'&desc='.$udesc);
  my $sh58 = &encode_base58($shash);
  $sh58 = 'YNnxpaXJUdRtyLbYwQUQbJ' if ($slink eq '');

  print "Content-Type: text/html\r\n";
  print "\r\n";
  print '<meta charset="UTF-8">';

  my $url = sprintf 'http://%s%s?sh58=%s',$ENV{HTTP_HOST},$ENV{REQUEST_URI},$sh58;
  my $qurl = $url; $qurl =~ s/([?&])/sprintf('%%%02x',ord($1))/eg;

  printf qq'<link rel="stylesheet" type="text/css" href="../style.css">\n';
  if ($lang eq 'fr') {
  printf "<div class=content>Votre lien public vers %s est<br><a href=%s>%s</a>\n",$desc,$url,$url;
  printf qq'<br>and son QR code est le suivant<br><img alt="%s" src="%s%s">\n',$url,$chart,$qurl;
  } else {
  printf "<div class=content>Your public link to %s is<br><a href=%s>%s</a>\n",$desc,$url,$url;
  printf qq'<br>and its QRcode is<br><img alt="%s" src="%s%s">\n',$url,$chart,$qurl;
  }
  # append map file ...
  local *F;open F,'>>','../map.yml';
  printf F qq'%s:\n - "%s"\n - "%s"\n - "%s"\n',$sh58,$slink,$desc,$owner;
  close F;
  if ($lang eq 'fr') {
  print "<br><br>Merci beaucoup\n<br>+michelc\n";
  print "</div><br><br><div class=content>Note: ceci est un service assez basique,\npour l'instant il ne s'agit que d'un REDIRECT\n";
  print " sans liste noire ni filtres sofistiqués ou captcha.\n";
  print "<br>Toutefois cela devrait suffir pour filtrer la plupart des spam,";
  print " nous nous améliorerons par la suite, avec d'autres mecanisms anti-spam\n";
  } else {
  print "<br><br>Thank you\n<br>+michelc\n";
  print "</div><br><br><div class=content>Note: this is a very basic service,\nfor now this is a simple REDIRECT\n";
  print " without blacklist nor fancy filter nor captcha.\n";
  printf "<br>However this should be enough filter most spam, we will improve it over time,".
         "with challenge response or other anti-spam mechanism\n";
  #printf "<br>param: %s...\n",Dump($param);
  print "</div>\n";
  }


# ----------------------------------------------------------------------------------------
# REDIRECT :
# 
#  sh58: safe link shortcut 
#
} elsif (exists $param->{sh58}) {
  my $sh58 = $param->{sh58} || 'YNnxpaXJUdRtyLbYwQUQbJ';
  sleep 3;
  my $map = LoadFile('../map.yml');
  if (exists $map->{$sh58}) {
     my $url = $map->{$sh58}[0] || 'http://wa.me/41767609400';;
     my $desc = $map->{$sh58}[1] || 'Default WhatsApp Group';
     my $owner = $map->{$sh58}[2] || 'unnamed';
     print qq'Status: 302 "Moved"\r\n';
     printf "X-sh58: %s\n",$sh58;
     printf "X-desc: %s\n",$desc;
     printf "X-Location: %s\r\n",$url;
     print "Content-Type: text/html; charset=utf-8\r\n";
     print "\r\n";
     printf qq'<meta http-equiv="Refresh" content="60;URL=%s">\n','https://www.ic3.gov/';
     printf qq'<link rel="stylesheet" type="text/css" href="../style.css">\n';
     print "<div class=content>\n";
     if ($lang eq 'fr') {
     printf qq'<h3>Vous allez être redirigé vers: "<a href="%s">%s</a>" dans quelques secondes<br><small>(après que vous ayez coché la bonne case)</small></h3>\n',$url,$desc;
     printf qq'note: <a href="http://duckduckgo.com/?q=!g+%s">%s</a> est un groupe maintenu par %s\n',$desc,$desc,$owner;
     } else {
     printf qq'<h3>you will be REDIRECTed to: "<a href="%s">%s</a>" in few secondes<br><small>(after you check the box)</small></h3>\n',$url,$desc;
     printf qq'note: <a href="http://duckduckgo.com/?q=!g+%s">%s</a> is a group run by %s\n',$desc,$desc,$owner;
     print "</div><br><div class=content>\n";
     }

     my $qurl = sprintf 'http://%s%s',$ENV{HTTP_HOST},$ENV{REQUEST_URI};
        $qurl =~ s/([?&])/sprintf('%%%02x',ord($1))/eg;
     my $chart = 'https://chart.googleapis.com/chart?cht=qr&choe=UTF-8&chld=H&chs=240&chl=';
     printf qq'<img alt="%s" title="%s" src="%s%s" align=right>\n',$sh58,$desc,$chart,$qurl;
     if ($lang eq 'fr') {
     print "S'il vous plait remplissez le formulaire ci-dessous (tous les champs sont optionels)\n";
     print "<br><br>Merci.\n";
     print "<br>-- La patrouille Safer℠\n";
     print "<h4>Mentions Légales</h4>\n";
     print qq'Je sousigné(e), <input type=text name=name placeholder="(Nom)",>\n';
     print qq'<br>attestes que je suis bien la personne que je pretend être\n<br>*ET*\n<br>'; 
     print "<br><input type=checkbox id=chkb onclick='myfunc()'> en cochant cette case, je certifie que je suis un être humain qui n'opère aucune tache automatisés,";
     printf "<br>et je vais me soumettre aux règles d'usage tu groupe (%s) je rejoins.\n",$desc;
     print qq'<br><br>Date: <input type=date name=date">\n';
     print qq'<br>Signature: <input type=password name=sig">\n';
     print "</div>\n";
     printf "<br><br><small align=right id=ftnote>note: Your <a href=http://https://whatismyipaddress.com/ip/%s>IP address</a> has just been logged (%s).</small>\n",$ip,$ENV{REMOTE_ADDR};
     } else {
     print "Please fill the form below (all fields are optional)\n";
     print "<br><br>Thanks.\n";
     print "<br>--Safer℠ Patrol\n";
     print "<h4>Legal claims</h4>\n";
     print qq'I undersigned, <input type=text name=name placeholder="(name)",>\n';
     print qq'<br>testify I am who I really am\n<br>*AND*\n<br>'; 
     print '<br><input type=checkbox id=chkb onclick="myfunc()"> by checking this box, you certify you are a human being not operating any sort of automated tasks,';
     printf "<br>and I will comply with the rules of the group (%s) I am joining.\n",$desc;
     print qq'<br><br>Date: <input type=date name=date">\n';
     print qq'<br>Signature: <input type=password name=sig">\n';
     print "</div>\n";
     printf "<br><br><small align=right id=ftnote>note: Votre <a href=http://https://whatismyipaddress.com/ip/%s>Adresse IP</a> a été enregistrée (%s).</small>\n",$ip,$ENV{REMOTE_ADDR};
     }
     printf <<'SCRPT',substr($url,0,10),substr($url,10);
<script> function myfunc(){
if(document.getElementById("chkb").checked) { location.href = "%s" + "%s" }
}
</script>
SCRPT

  } else {
     print qq'Status: 404 "Not Found"\r\n';
     print "Content-Type: text/plain\r\n";
     print "\r\n\r\nNo Hash\n";
  }
# ----------------------------------------------------------------------------------------
} else {
  print "Content-Type: text/plain\r\n";
  print "\r\n";
  print "nop !\n";
}
# ----------------------------------------------------------------------------------------
exit 1;

sub shake {
  my $len = shift;
  my $msg = Crypt::Digest::SHAKE->new(256);
     $msg->add(join'',@_);
  my $digest = $msg->done($len);
  return $digest; 
}
sub encode_base58 {
  use Math::BigInt;
  use Encode::Base58::BigInt qw();
  my $bin = join'',@_;
  my $bint = Math::BigInt->from_bytes($bin);
  my $h58 = Encode::Base58::BigInt::encode_base58($bint);
  $h58 =~ tr/a-km-zA-HJ-NP-Z/A-HJ-NP-Za-km-z/;
  return $h58;
}
