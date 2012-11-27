#!/bin/bash

# script to make a surface, interpolate it to fill nans, then cut it up and
# spit out grids of the data to be used in matlab.

indir=./
infile=ws_1m_blockmean.txt
prefix=ws

inc=$1 # subsampling size

if [ ! -d ./grids/cut_domain/$inc/ ]; then
   mkdir -p ./grids/cut_domain/$inc
fi

cutgrid(){
   todo=$(echo "scale=2; $(wc -l < ./splits/vertical_$inc.txt)*$(wc -l < ./splits/horizontal_$inc.txt)" | bc -l)
   incr=1
   while read xline; do
      while read yline; do
         west=$(echo $xline | cut -f1 -d\ )
         east=$(echo $xline | cut -f2 -d\ )
         south=$(echo $yline | cut -f1 -d\ )
         north=$(echo $yline | cut -f2 -d\ )
         area=-R${west}/${east}/${south}/${north}
         suffix=_${west}_${east}_${south}_${north}

         echo "$incr of $todo: ${prefix}${suffix}.grd"
         incr=$(($incr+1))
         grdcut $area ./grids/${infile%.txt}.grd \
            -G./grids/cut_domain/$inc/${prefix}${suffix}.grd 2> /dev/null
      done < ./splits/vertical_$inc.txt
   done < ./splits/horizontal_$inc.txt
   echo "Done."
}

cutgrid
