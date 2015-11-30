#!/bin/bash
if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters (repertoire des git)"
	exit 0
fi
outfile="$(pwd)/log/gitpushpull-`date +%Y-%m-%d-%H-%M-%S`.txt"
cd $1
for f in ./*;
  do
	if [ -d $f ]; then
	cd $f
	if [ -d .git ]; then
      echo $f >> $outfile
	  git config --global push.default matching >> $outfile
	  git pull >> $outfile
	  git push >> $outfile
	fi;
	cd ..
	fi;
  done;
