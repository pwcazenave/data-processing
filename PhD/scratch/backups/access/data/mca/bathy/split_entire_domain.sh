#!/bin/bash

# script to cut the entire domain into smaller sections

#set -x

gmtset D_FORMAT=%.0f

#inc=400 # subsampling increment
inc=$1

#south=5613228
#west=598200
#north=5623984
#east=610623

area=$(grdinfo -I1 ./grids/ws_1m_blockmean.grd | sed 's/-R//g')
west=$(echo $area | cut -f1 -d'/')
east=$(echo $area | cut -f2 -d'/')
south=$(echo $area | cut -f3 -d'/')
north=$(echo $area | cut -f4 -d'/')

xiterations=$(echo "scale=0; ($east-$west)/$inc" | bc -l)
yiterations=$(echo "scale=0; ($north-$south)/$inc" | bc -l)

mkpoints(){
   \rm ./splits/vertical_$inc.txt ./splits/horizontal_$inc.txt

   touch ./splits/vertical_$inc.txt
   for ((y=1; y<=$yiterations; y++)); do
      max_y=$(echo "scale=0; $south+$inc" | bc -l)
      echo $south $max_y >> ./splits/vertical_$inc.txt
      south=$max_y
   done

   touch ./splits/horizontal_$inc.txt
   for ((x=1; x<=$xiterations; x++)); do
      max_x=$(echo "scale=0; $west+$inc" | bc -l)
      echo $west $max_x >> ./splits/horizontal_$inc.txt
      west=$max_x
   done

   \rm ./splits/grid_cut_wesn_$inc.txt
   touch ./splits/grid_cut_wesn_$inc.txt
   while read xline; do
      while read yline; do
         echo $xline $yline >> ./splits/grid_cut_wesn_$inc.txt
#         echo $xline $yline | awk '{print $2,$4}' >> ./splits/grid_cut.txt
      done < ./splits/vertical_$inc.txt
   done < ./splits/horizontal_$inc.txt

#   \rm ./splits/horizontal.txt ./splits/vertical.txt
}

mkpoints

exit 0
