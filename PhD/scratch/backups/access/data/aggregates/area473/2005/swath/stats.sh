#!/bin/bash

# script to determine the ideal bathymetric resolution of a given input file

set -e

for loop_value in 0.50 0.75 1.0; do

   echo "*************"
   echo "$loop_value"m

   # global variables
   text_res="$loop_value"m
   histogram=./images/stats_histogram_$text_res.ps
   image=./images/grid_stats_$text_res.ps
   h_area=-R0/10/0/100
   proj=-Jx0.001
   h_proj=-JX11/8
   proj_text=-JX22/30
   area_text=-R0/22/0/30
   gres=-I"$loop_value"
   gmtset D_FORMAT %7.2f

   # formatting etc
   gmtset ANNOT_FONT_SIZE 14
   gmtset LABEL_FONT_SIZE 14
   gmtset HEADER_FONT_SIZE 16
   gmtset ANNOT_FONT_SIZE_SECONDARY 14

   # only roll corrected bathy
   roll_input=./raw_data/roll_corrected_bathy.txt
   roll_stats_grid=./roll_stats_$text_res.grd
   roll_xyzstat=./raw_data/roll_xyzstat_$text_res.txt
   roll_area=-R307138/323270/5593136/5599952
   # qloud cleaned bathy - 2 merged pts files
   qloud_input=./raw_data/qloud_output.pts
   qloud_stats_grid=./qloud_stats_$text_res.grd
   qloud_xyzstat=./raw_data/qloud_xyzstat_$text_res.txt
   qloud_area=-R313748/323256/5594972/5599924
   qloud_proj=-Jx0.001

   echo -n "calculate bins... "
   xyz2grd $roll_area $gres $roll_input -An -G$roll_stats_grid
   xyz2grd $qloud_area $gres $qloud_input -An -G$qloud_stats_grid
   echo "done."

   echo -n "convert bin grid to ascii... "
   grd2xyz $roll_area $roll_stats_grid -S > $roll_xyzstat
   grd2xyz $qloud_area $qloud_stats_grid -S > $qloud_xyzstat
   echo "done."

   #echo "make a better grid... "
   #surface $roll_area $roll_xyzstat $gres -G$roll_stats_grid -T0.25
   #surface $qloud_area $qloud_xyzstat $gres -G$qloud_stats_grid -T0.25
   #grdmask $roll_area $roll_xyzstat -Groll_mask_$text_res.grd $gres \
   # -N/NaN/1/1 -S1
   #grdmask $qloud_area $qloud_xyzstat -Gqloud_mask_$text_res.grd $gres \
   # -N/NaN/1/1 -S1
   #grdmath $roll_stats_grid roll_mask_$text_res.grd MUL = \
   #   $(basename $roll_stats_grid .grd)_surfaced.grd
   #grdmath $qloud_stats_grid qloud_mask_$text_res.grd MUL = \
   #   $(basename $qloud_stats_grid .grd)_surfaced.grd
   #echo "done."

   echo -n "imaging... "
   # roll
   grd2cpt $roll_area $roll_stats_grid \
      -Cwysiwyg -Z > .roll_stats.cpt
   gmtset D_FORMAT %6.0f
   grdimage $roll_area $proj $roll_stats_grid \
      -C.roll_stats.cpt -K -Xc -Y15 -P \
      -Ba500f250g500:"Eastings":/a500f250g500:"Northings":WeSn \
      > $image
   psscale -D15.2/5/5/0.5 -B20 -C.roll_stats.cpt -O -K >> $image
   pstext $proj_text $area_text -O -K << TEXT >> $image
   15 8 10 0.0 0 1 Soundings
TEXT

   # qloud
   gmtset D_FORMAT %7.2f
   grd2cpt $qloud_area $qloud_stats_grid\
      -Cwysiwyg -Z > .qloud_stats.cpt
   gmtset D_FORMAT %6.0f
   grdimage $qloud_area $qloud_proj \
      $qloud_stats_grid \
      -C.qloud_stats.cpt -O -K \
      -Ba500f250g500:"Eastings":/a500f250g500:"Northings":WeSn\
      -Y-13 >> $image
   psscale -D8/4.5/5/0.5 -B10 -C.qloud_stats.cpt -X2 -O -K >> "$image"
   pstext $proj_text $area_text -O << TEXT >> $image
   8 7.5 10 0.0 0 1 Soundings
TEXT
   echo "done."

   gmtset D_FORMAT %6.0f

   echo -n "imaging... "
   # roll
   pshistogram $h_area $h_proj $roll_xyzstat \
      -Ba2f1g2:"Number of raw data points per bin":/a20f10g20:,%:WeSn \
      -G200/0/100 -P -L0/0/0 -T2 -W1 -Xc -Y16 -Z1 -K > "$histogram"
   # qloud
   pshistogram $h_area $h_proj $qloud_xyzstat \
      -Ba2f1g2:"Number of raw data points per bin":/a20f10g20:,%:WeSn \
      -G0/100/200 -P -L0/0/0 -T2 -W1 -Y-12 -Z1 -O >> "$histogram"

   echo -n "conversion... "
   ps2pdf -sPAPERSIZE=a4 $histogram ./images/$(basename $histogram .ps).pdf
   ps2pdf -sPAPERSIZE=a4 $image ./images/$(basename $image .ps).pdf
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      -sOutputFile=./images/$(basename $histogram .ps).jpg $histogram \
      > /dev/null
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      -sOutputFile=./images/$(basename $image .ps).jpg $image > /dev/null
   echo "done."
   gmtset D_FORMAT %g

done

exit 0
