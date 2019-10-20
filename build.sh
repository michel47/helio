git pull
bundle exec jekyll build
rsync -auz _site/ $WWW
rsync -auz _site/ $HOME/odrive/tommy/public_html

curl https://iph.heliohost.org/cgi/deploy.pl
