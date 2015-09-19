#!/bin/bash

dir="$HOME/github_repos/SteamOS-Tools.wiki"

# update TOC for a given wiki page
# hard-coded to local DIR on workstation

cd $dir
git pull 
ls

echo -e "Update which wiki page?\n"
sleep 1s
read -ep "Choice: " wiki_page

doctoc $wiki_page
git add .
git commit -m "update TOC"
git push origin master