#!/bin/bash
rm ./gitpushpull.txt
for f in ./*;
  do
     [ -d $f ] && cd $f && echo $f >> ../gitpushpull.txt && git pull >> ../gitpushpull.txt &&  git push >> ../gitpushpull.txt && cd ..
  done;
