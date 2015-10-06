#!/bin/bash
<<<<<<< HEAD
rm ./gitlistdiff.txt
for f in ./*;
  do
     [ -d $f ] && cd $f && echo $f >> ../gitlistdiff.txt && git show --pretty="format:" >> ../gitlistdiff.txt && cd ..
=======
if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters (repertoire des git)"
	exit 0
fi
cd $1
outfile="../gitlistdiff-`date +%Y-%m-%d-%H-%M-%S`.txt"
for f in ./*;
  do
	if [ -d $f ]; then
	cd $f
	if [ -d .git ]; then
	 echo $f >> $outfile 
	 git show --pretty="format:" >> $outfile
	 echo $f >> $outfile
	fi;
	cd ..
	fi;
>>>>>>> e96577a761ae74ca8b8aa69e470ca63149ed7502
  done;
