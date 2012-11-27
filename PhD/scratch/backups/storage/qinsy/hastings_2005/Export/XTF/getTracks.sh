#!/bin/bash

rm ~/desktop/all_tracks.txt; touch ~/desktop/all_tracks.txt

for i in "$@"; do 
#	dumpxtf "$i" > ~/desktop/"${i%.*}.dump"
	grep lat\( ~/desktop/"${i%.*}.dump" | awk '{print "'"${i:0:4}"'",$4,$3}' > ~/desktop/"${i%.*}_1.dump"
	grep m\ Number ~/desktop/"${i%.*}.dump" | awk '{print "2005/"$6,$7}' > ~/desktop/"${i%.*}_2.dump"
	paste -d" " ~/desktop/"${i%.*}_1.dump" ~/desktop/"${i%.*}_2.dump" |
		awk '{print $1,$4,$5,$2,$3}' >> ~/desktop/all_tracks.txt
done
