#!/bin/bash
rm ./gitlistdiff.txt
for f in ./*;
  do
     [ -d $f ] && cd $f && echo $f >> ../gitlistdiff.txt && git show --pretty="format:" >> ../gitlistdiff.txt && cd ..
  done;
