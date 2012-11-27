#!/bin/bash

for i in "$@"; do
	sed -i 's/;/\ /g' "$i"
#	awk '{printf "%2i %08i %s0 %.2f %.2f %.7f %.7f\n", "'"${i:7:2}"'",$1,$2,$3,$4,$5+($6/60),$8+($9/60)}' "$i" > "${i%.*}_awked.txt"
	awk '{printf "%s %08i %s0 %.2f %.2f\n", "'"${i:7:2}"'",$1,$2,$3,$4}' "$i" > "${i%.*}_awked.txt"
#	echo "line,date,time,eastings,northings,latDD,longDD" > "${i%.*}_awked.csv"
	echo "line,date,time,eastings,northings" > "${i%.*}_awked.csv"
	tr " " "," < "${i%.*}_awked.txt" >> "${i%.*}_awked.csv"
done

#echo "line,date,time,eastings,northings,latDD,longDD" > all_tracks.csv
echo "line,date,time,eastings,northings" > all_tracks.csv
for i in "$@"; do
	grep -v [A-Za-z] "${i%.*}_awked.csv" >> all_tracks.csv
done
