#!/bin/bash
rm ./gitlistremote.txt
for f in ./*;
  do
     [ -d $f ] && cd $f && echo $f >> ../gitlistremote.txt && git remote -v  >> ../gitlistremote.txt && cd ..
  done;
