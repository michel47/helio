bundel exec jekyll build
rsync -auz _site/ $HOME/odrive/tommy/public_html
curl https://iph.heliohost.org/cgi/deploy.pl
