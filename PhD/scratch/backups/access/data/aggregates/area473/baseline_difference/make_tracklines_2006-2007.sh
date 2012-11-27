#!/bin/bash
#
# ok, so the idea is this: take the tracklines from the 2005 and 2006 survey
# and use those to take transects across the difference grids i've just made.
# these should hopefully show some sort of tidal trend, which might be able
# to correct the data. that's the theory. time to test it.

gmtset D_FORMAT %.2f
gmtset ANNOT_FONT_SIZE_SECONDARY 10
track_dir=./tracklines/2006/
diff_grid=./grids/area473_07-06.grd

mktrans() {
   # use the tracklines to make transects
   for line in "$track_dir"l*.line; do
      echo -n "making transect of $line... "
      awk '{print $3,$4,$1,$2}' $line | \
         grdtrack -G$diff_grid -S > ${line%.line}.pfl
      echo "done."
   done
}

dorm() {
   # remove all the ones that are outside the region (based on the profiles i
   # being 0 bytes...
   for file in "$track_dir"l*.pfl; do
      size=$(stat -c%s $file)
      if [ $size == "0" ]; then
         \rm $file
      fi
   done
}

catpfl() {
   # make a single transect file from lines 0015 to 0027 - the consecutively
   # collected lines.
   echo -n "create a single profile... "
   cat "$track_dir"l*.pfl > "$track_dir"catted_profiles.pfl
   echo "done."
}

plot() {
   # plot the total profile
   echo -n "plot the new profile... "
   gmtset INPUT_DATE_FORMAT yy/mm/dd
   #area=$(awk '{print $3"T"$4,$5}' "$track_dir"catted_profiles.pfl | minmax \
   #   -I0.1/1 -fT)
   area=-R2006-09-11T09:36:00/2006-09-12T00:00:00/-2/2
   proj=-JX23/15
   outfile=./images/total_profile_2006.ps

   awk '{print $3"T"$4,$5}' "$track_dir"catted_profiles.pfl | sort | \
      psxy $area $proj -W3/0/100/200 \
      -Bpa2Hf1Hg2H:"Date":/a1f0.5g1:"Difference (m)":WeSn -Bsa1D/0 \
      -Xc -Yc -K > $outfile
   # add the tidal curve from the gps used to correct the bathy
   gmtset INPUT_DATE_FORMAT dd-mm-yyyy
   awk '{if (NR%20==0 && $2<57) print $1, $2}' \
      ../../tides/2006/raw_data/gps_tide.txt | \
      psxy -R2006-09-11T09:36:00/2006-09-12T00:00/49/57 $proj -W3/100/200/0 \
      -B0/a1f0.5g1:"GPS Height (m) WGS84":E -O -K -Sc0.1 \
      >> $outfile
   sort -g ../../tides/2006/raw_data/gps_tide_trend.txt | \
      awk '{if ($3<58) print $1,$2}' | \
      psxy -R2006-09-11T09:36:00/2006-09-12T00:00/49/57 $proj \
      -W3/100/200/50 -B0/a1f0.5g1:"GPS Height (m) WGS84":E -O -K >> $outfile
   echo "done."

   # add a key:

   # set up the dimensions
   page=-R0/35/0/28
   a4=-JX35c/28c

   # plot the various labels
   psbasemap $page $a4 -O -K -P -B0wesn -X-4.5 -Y-7.5 >> $outfile
   pstext $page $a4 -Bwesn -X1 -Y0 -O -K << TEXT >> $outfile
   7 4.9 12 0.0 0 1 Sampled Difference Grid
   19 4.9 12 0.0 0 1 RTK GPS Height
TEXT

   # plot the lines for the key
   psxy $page $a4 -O -K -W5/0/100/200 << BLUE_LINE >> $outfile
   6 5
   6.5 5
BLUE_LINE
   psxy $page $a4 -O -W5/100/200/0 << GREEN_LINE >> $outfile
   18 5
   18.5 5
GREEN_LINE
}

conv() {
   echo -n "converting $outfile to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress "$outfile" \
      ${outfile%.ps}.pdf
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=${outfile%.ps}.jpg" \
      "$outfile" > /dev/null
   echo "done."
}

#mktrans           # generate the profiles
#dorm            # remove null profiles
#catpfl          # cat the profiles
plot            # plot the profiles
conv            # convert the output

exit 0
