#!/bin/bash

# create variables
file=$HOME/.config/pianobar/song.info
while read L; do
	k="`echo "$L" | cut -d '=' -f 1`"
	v="`echo "$L" | cut -d '=' -f 2`"
	export "$k=$v"
done < <(grep -e '^\(title\|artist\)' /dev/stdin) # don't overwrite $1...

case $1 in
	songstart)
		echo "SONG: $title" > $file
		echo "ARTIST: $artist" >> $file
	;;
esac
