#!/bin/bash
if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters (repertoire des git)"
	exit 0
fi
cd $1
outfile="(dirname $0)/log/gitlistdiff-`date +%Y-%m-%d-%H-%M-%S`.txt"
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
  done;
