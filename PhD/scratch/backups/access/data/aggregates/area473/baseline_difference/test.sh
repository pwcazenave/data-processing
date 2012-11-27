#!/bin/bash

total=$(wc -l ./y.along)
count=1
for i in $(<y.along); do
   echo $count "of" $total
   awk '/'$i'/' ./asdfas.awked | minmax -C | \
      awk '{print $1,$3"\n"$2,$4}' \
      >> ./grids/outline.y
   count=$((count+1))
done
