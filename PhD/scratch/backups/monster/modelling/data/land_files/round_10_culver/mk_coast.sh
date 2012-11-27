#!/bin/bash

# script to make the coastline from pscoast.

. ~/.bash_profile > /dev/null

# TODO: Make it so I can subdivide with floating points.

set -e

gmtset OUTPUT_DEGREE_FORMAT=+D

westseed=${westseed:--20}
eastseed=${eastseed:-20}
southseed=${southseed:-40}
northseed=${northseed:-70}

echo $westseed $eastseed $southseed $northseed

ssize=5

proj=-Jm0.4

mktiles(){
   echo "output tiled data... "
   if [ $westseed -lt 0 -o $eastseed -lt 0 ]; then
      nwe=$(echo "scale=0; ((sqrt($westseed^2)+sqrt($eastseed^2)))/$ssize" | bc -l)
   else
      nwe=$(echo "scale=0; ($eastseed-$westseed)/$ssize" | bc -l)
   fi

   if [ $northseed -lt 0 -o $southseed -lt 0 ]; then
      nns=$(echo "scale=0; ((sqrt($northseed^2)+sqrt($southseed^2)))/$ssize" | bc -l)
   else
      nns=$(echo "scale=0; ($northseed-$southseed)/$ssize" | bc -l)
   fi
   
   incseed=0

   for ((ns=0; ns<$nns; ns++)); do
      west=$westseed
      east=$eastseed
      if [ $ns -eq 0 ]; then
         south=$southseed
      else
         south=$north
         incseed=$(($incseed+1))
      fi
      north=$(echo "scale=2; $south+$ssize" | bc -l)
      total=$(echo "scale=0; $nns*$nwe" | bc -l)
      for ((we=0; we<$nwe; we++)); do
         curr=$(echo "scale=0; ($incseed*$nwe)+$we+1" | bc -l)
         echo $curr of $total
         east=$(echo "scale=2; $west+$ssize" | bc -l)
         pscoast $proj -R$west/$east/$south/$north -Df -I1 -W -A1000 -m > \
            ./tiles/gshhs_$west-$east-$south-$north.xy
         west=$east
      done
   done
   echo "done."
}

mkcsv(){
   echo -n "formatting to csv... "
   for i in ./tiles/*.xy; do
      echo "x,y" > ${i%.*}.csv
      grep -v [a-z] $i | awk 'OFS="," {print $1,$2}' >> ${i%.*}.csv
      nl=$(wc -l < ${i%.*}.csv)
      if [ $nl -eq 1 ]; then
         rm -f $i ${i%.*}.csv
      fi
   done
   echo "done."
}

mkmike(){
   echo -n "formatting for mike21... "
   for i in ./tiles/*.xy; do 
      grep -v [a-z] $i | \
         awk '{
            if ($1>'$eastseed') {
               print $1-360,$2,"1 0"
            } else {
               print $1,$2,"1 0"
            }
         }' > ${i}z
   done
   echo "done."
}

mkimg(){
   echo -n "make an image... "
   pscoast -R$westseed/$eastseed/$southseed/$northseed \
      $proj -P -Xc -Yc -Df -W -A27 -Ba5g1 \
      > ./gshhs.ps
   echo "done."
   formats ./gshhs.ps
}

mksingle(){
   echo -n "make a single output... "
   gmtset D_FORMAT=%.2f
   pscoast -R$westseed/$eastseed/$southseed/$northseed \
      $proj -P -Xc -Yc -Df -I1 -W -A10 -m \
      > gshhs_csm_raw.xyz
   gmtset D_FORMAT=%g
   grep -v [a-z] ./gshhs_csm_raw.xyz | \
      awk '{print $1,$2,"1 0"}' > ./gshhs_csm.xyz
   echo "done."
}

mktiles
mkcsv
mkmike
#mkimg
mksingle

exit 0
