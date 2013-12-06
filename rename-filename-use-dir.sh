#!/bin/bash
for dir in `ls`; do
	if [[ -d $dir ]]; then
		echo $dir
		cd $dir && pwd
		for file in `ls`; do
			echo "$file -> $dir.${file#*.}"
			echo "press any key..."; read a
		done
		cd ..
	fi
done