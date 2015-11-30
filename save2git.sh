#!/bin/bash
if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters ( \"message\""
	exit 0
fi
git add -A 
git commit -am  "\"$2\""
git push
