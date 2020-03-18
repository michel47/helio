#

set -e
script="$1"
path='dynsm.ml/cgi-bin';
export WWW=${WWW:-/usr/local/share/doc/civetweb/public_html}
perl $WWW/helio/cgi-bin/testing.pl 1> /dev/null
echo "url: https://yoogle.com:8088/cgi-bin/testing.pl/$path/$script;"

echo "// perl execution: "
perl ../sites/$path/$script

echo "// curl testing.pl execution: "
curl http://yoogle.com:8088/helio/cgi-bin/testing.pl/$path/$script;

echo "// curl ../sites/$path execution: "
curl http://yoogle.com:8088/helio/sites/$path/$script;
