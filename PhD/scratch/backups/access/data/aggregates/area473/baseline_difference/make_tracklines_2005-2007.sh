#!/bin/bash
#
# ok, so the idea is this: take the tracklines from the 2005 and 2006 survey
# and use those to take transects across the difference grids i've just made.
# these should hopefully show some sort of tidal trend, which might be able
# to correct the data. that's the theory. time to test it.

# ok. let's start with the 2005 data, since i have the tracklines for it.

gmtset D_FORMAT %.2f

track_dir=./tracklines/2005
diff_grid=./grids/area473_07-05.grd

mktrans(){
   # use the tracklines to make transects
   for line in "$track_dir"/0*.line; do
      echo -n "making transect of $line... "
      awk '{print $3,$4,$1,$2}' $line | \
      grdtrack -G$diff_grid -S > ${line%.line}.pfl
      echo "done."
   done
}

dorm(){
   # remove all the ones that are outside the region (based on the profiles
   # being 0 bytes...
   for file in $track_dir/*.pfl; do
      size=$(stat -c%s $file)
      if [ $size == "0" ]; then
         rm $file #${file%.pfl}.trk
      fi
   done
}

catpfl(){
   # make a single transect file from lines 0015 to 0027 - the consecutively
   # collected lines.
   echo -n "create a single profile... "
   #cat $track_dir/0*.line > $track_dir/catted_lines.trk
   cat $track_dir/0*.pfl > $track_dir/catted_profiles.pfl
   echo "done."
}
plot(){
   # plot the total profile
   echo -n "plot the new profile... "
   gmtset INPUT_DATE_FORMAT dd/mm/yyyy
   gmtset TIME_FORMAT_PRIMARY full
   gmtset OUTPUT_DATE_FORMAT yyyy-mm-dd
   gmtset PLOT_CLOCK_FORMAT hh:mm
   gmtset ANNOT_FONT_SIZE_SECONDARY 10

   area=-R2005-09-16T18:00:00/2005-09-17T09:00:00/0/3.5
   tide_area=-R2005-09-16T18:00:00/2005-09-17T09:00:00/0/7
   proj=-JX25cT/15

   plot_data=$track_dir/catted_profiles.pfl # removed data from 15th Sept
   outfile=./images/timed_profile_2005.ps

   # plot the difference grid info
   awk '{print $3"T"$4,$5}' $plot_data | \
   psxy $area $proj -W3/0/100/200 -K -Xc -Yc \
      -Bpa1Hf30Mg1H:"Date":/a1f0.5g1:"Difference (m)":WeSn -Bsa1D/0 \
      > $outfile

   # overlay the 2005 tidal curve
   gmtset INPUT_DATE_FORMAT yyyy-mm-dd
   intide=../../tides/2005/2005NHA_sept.txt

   psxy $tide_area $proj $intide -W3/100/200/0 -O -K \
      -B0/a1f0.5g1:"Height (m) CD":E \
      >> $outfile
   echo "done."

   # add a key:

   # set up the dimensions
   page=-R0/35/0/28
   a4=-JX35c/28c

   # plot the various labels
   psbasemap $page $a4 -O -K -P -B0wesn -X-4 -Y-7.5 >> $outfile
   pstext $page $a4 -Bwesn -X1 -Y0 -O -K << TEXT >> $outfile
   7 4.9 12 0.0 0 1 Sampled Difference Grid
   19 4.9 12 0.0 0 1 Newhaven Tidal Height
TEXT

   # plot the lines for the key
   psxy $page $a4 -O -K -W5/0/100/200 << BLUE_LINE >> $outfile
   6 5
   6.5 5
BLUE_LINE
   psxy $page $a4 -O -K -W5/100/200/0 << GREEN_LINE >> $outfile
   18 5
   18.5 5
GREEN_LINE
}

conv(){
   echo -n "converting $outfile to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress "$outfile" \
      ${outfile%.ps}.pdf
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=${outfile%.ps}.jpg" \
      "$outfile" > /dev/null
   echo "done."
}

mktrans           # generate the profiles
dorm            # remove null profiles
catpfl          # cat the profiles
plot            # plot the profiles
conv            # convert the output

exit 0
