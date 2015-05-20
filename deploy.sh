#! /bin/bash

jekyll build
rm -rf ~/.jekyll

cp -rf _site ~/.jekyll/

cd ~/.jekyll/ 
git init
git add .
git commit -am 'deploy'
git remote add origin git@github.com:nodeonly/nodeonly.github.io.git
git push -u origin master -f




