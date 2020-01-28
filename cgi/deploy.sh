#

# https://iph.heliohost.org/cgi/testing.pl/cmd.pl
set -e
set -x

# getting a clean "checkout"
cd ~/repositories/helio
# reset see [*](https://www.ocpsoft.org/tutorials/git/reset-and-sync-local-respository-with-remote-branch/)
if false; then
git fetch origin
git reset --hard origin/master
git clean -f -d
fi

git status
git pull

# deploy : i.e. mirroring to public_html ...
cd ~/public_html
rsync -avuz ../repositories/helio/_site/index.html .
rsync -avuz ../repositories/helio/_site/style.css .
rsync -avuz ../repositories/helio/cgi-bin/ cgi-bin
rsync -avuz ../repositories/helio/cgi/ cgi
#rm cgi-bin
#ln -s /home/michelc/repositories/helio/cgi-bin cgi-bin

ls -l cgi-bin

