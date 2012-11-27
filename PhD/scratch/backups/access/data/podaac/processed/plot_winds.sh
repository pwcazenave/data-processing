#!/bin/bash

# make a geotiff of the wind data for july, 2007.

gmtset PLOT_DEGREE_FORMAT F

total=$(ls ./2007-07/vectors/*.txt | wc -l)
count=1

# let's do all the data...
for file in ./2007-07/vectors/*.txt; do
   if [ $total -lt 100 ]; then
      if [ $count -lt 10 ]; then
         echo -en "$count of $total...\b\b\b\b\b\b\b\b\b\b"
      else
	 echo -en "$count of $total...\b\b\b\b\b\b\b\b\b\b\b"
      fi
   elif [ $total -ge 100 ]; then
      if [ $count -lt 1000 ]; then
	 echo -en "$count of $total...\b\b\b\b\b\b\b\b\b\b\b"
      else
	 echo -en "$count of $total...\b\b\b\b\b\b\b\b\b\b\b\b"
      fi
   fi

#   echo -n "formatting $file... "
   outdir=./2007-07/vectors/formatted/
   # get the day and year for the output filename
   name=$(grep Day: $file | awk '{print $4"_"$2}')
   # print only the columns of interest and remove the junk at the eof.
   #awk 'FNR>10{if ($5<255) print $1, $2, $5}' $file | \
   awk 'FNR>10{if ($5<255) print $1, $2, $5}' $file | \
      sed -e :a -e '$d;N;2,23ba' -e 'P;D' \
      > $outdir/$name.dat
#   echo "done."

   # make a grid file and convert to a geotiff
#   echo -n "make a grid file: $griddir/$name.grd "
   griddir=./2007-07/grids
   tiffdir=./2007-07/geotiffs
   imgdir=./2007-07/images
   area=-R-10/5/47.5/52.5
   proj=-Jm1.5
   xyz2grd $area $outdir/$name.dat -G$griddir/$name.grd -I30m
#   echo "done."
#   echo -n "make a postscipt image... "
   grd2cpt $griddir/$name.grd -Z -Cwysiwyg $area > $name.cpt
   grdimage $area $proj -C$name.cpt -K $griddir/$name.grd -Xc -Yc \
      -Ba1f0.5g1:."Wind data for day $(echo $name | tr "_" " " | \
	 awk '{print $2", "$1}')":WeSn \
      > $imgdir/$name.ps
   # add a coastline for the area
   pscoast $area $proj -Ba1f0.5g1WeSn -Df -G0/0/0 -O \
      -N1/255/255/255 -W1/255/255/255 >> $imgdir/$name.ps
#   echo "done."
#   echo -n "make a geotiff: $tiffdir/$name.tif "
   mbgrdtiff -I$griddir/$name.grd -C$name.cpt -O$tiffdir/$name.tif &>/dev/null
#   echo "done."
   # clean up
   \rm -f $name.cpt
   count=$(( $count + 1 ))
done

# convert postscipt to pdf
echo ""
echo -n "convert images to pdf... "
cd $imgdir
find ./ -iname "*.ps" -exec ps2pdf -sPAPERSIZE=a4 {} \;
cd - &>/dev/null
echo "done."

exit 0
