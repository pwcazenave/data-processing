#!/bin/bash

# script to make geotiffs of all the netcdf files from the podaac ftp site.
# scratch geotiffs - data are in kms. need to use grdimage and then .tfw files.
# cannot use this data to make vector plots.

gmtset D_FORMAT %g

grddir=./2007/netcdf_grids
tiffdir=./2007/images
count=1

for file in $grddir/*.nc; do
   if [ $count -lt 10 ]; then
      echo -en "$count\b"
   elif [ $count -lt 100 ]; then
      echo -en "$count\b\b"
   else
      echo -en "$count\b\b\b"
   fi

   year=$(echo $file | cut -c31-34)
   day=$(echo $file | cut -c35-37)
   # set the environment variables
   area=$(grdinfo -I1 $file)
   proj=-Jx0.015

   # make a colour palette file
#   grd2cpt $file -Z -Cwysiwyg $area > ./wind.cpt
   makecpt -T1/30/0.1 -Z -Cwysiwyg > ./wind.cpt

   # make the image
   grdimage $area $proj $file \
   -B100:"Distance east from 0@+o@+ Greenwich Meridian (km)":/100:"Distance north from -90@+o@+S (km)"::."Global wind speed for day $day, $year":WeSn \
      -C./wind.cpt -Xc -Yc -K \
      > $tiffdir/"$year"-"$day".ps

   # add one to the count
   count=$(( $count+1 ))
#   \rm ./wind.cpt
done

for i in $tiffdir/*; do
   gs -sDEVICE=jpeg -dNOPAUSE -dBATCH -sPAPERSIZE=a4 -r100 \
      -sOutputFile=$tiffdir/$(basename $i .ps).jpg $i &>/dev/null
done
