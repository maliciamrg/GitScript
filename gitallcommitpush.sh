#!/bin/bash
if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters (repertoire des git \"message\""
	exit 0
fi
outfile="$(pwd)/log/gitallcommitpush-`date +%Y-%m-%d-%H-%M-%S`.txt"
cd $1
for f in ./*;
  do
	if [ -d $f ]; then
	cd $f
	if [ -d .git ]; then
      echo "=====> $f <=====" >> $outfile
	  git add -A >> $outfile
	  git commit -am  "\"gitallcommitpush $2\"">> $outfile
	  git push >> $outfile
	  git pull >> $outfile
	fi;
	cd ..
	fi;
  done;
