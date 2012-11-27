#!/bin/bash

# script to check the differences in depth being generated during the regridding
# from 2 to 1 minutes of the ETOPO bathy grid.

gmtset D_FORMAT=%g
gmtset PLOT_DEGREE_FORMAT F
gmtset ANNOT_FONT_SIZE 12
gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 14
gmtset ANNOT_FONT_SIZE_SECONDARY 10

area=-R-10/5/47.5/52.5
proj=-Jm1

cmap_grid=../../cmap/grids/cmap_bathy.grd
britned_grid=../../diff_grids/grids/britned_sn_sea_0.002deg.grd
seazone_grid=../../seazone/grids/seazone.grd
gebco_grid=../../gebco/plot/gebco_bathy.grd
etopo_grid=../../etopo/etopo_bathy.grd

slong=1
slat=50.75
elong=3.25
elat=52.25

colours=(34/139/34 200/0/50 160/32/240 255/127/36 0/0/0 188/238/104 100/100/100 0/0/128 0/191/255)
grids=($cmap_grid $seazone_grid $gebco_grid $britned_grid)

outfile=../images/cmap_seazone_gebco_britned_transect.ps

mk_transect(){
   # make a transect (fairly long)
   echo -n "making the profile... "
   project -C$slong/$slat -E$elong/$elat -G0.5 -Q > ./pointonemin_transect.trk
   echo "done."

   # get the values from the grid
      echo -n "take the depth values from the grids... "
   for ((i=0; i<${#grids[@]}; i++ )); do
      grdtrack ./pointonemin_transect.trk -G"${grids[i]}" -S \
         > ./profiles/$(basename "${grids[i]%.grd}".pfl)
   done
   echo "done."
}

plot_profile(){
   # plot the profiles
   echo -n "plot the profiles... "
   #p_area=$(awk '{print $3, $4}' ./profiles/etopo_bathy.pfl | minmax -I2)
   p_area=-R0/250/-60/-5
   p_proj=-JX15c/9c

   annot=-Ba50f10g50:,-km::"Distance along line":/a10f2g10:,-m::"Depth":WeSn

   psbasemap $p_area $p_proj "$annot" -Xc -Y18 -P -K > $outfile


   for ((i=0; i<${#grids[@]}; i++)); do
      awk '{print $3,$4}' ./profiles/$(basename "${grids[i]%.grd}".pfl) | \
         psxy $p_area $p_proj -B0 -O -K -W3/"${colours[i]}" \
         >> $outfile
   done

   pstext -N $p_area $p_proj -O -K -W255/255/255 << LABELS >> $outfile
   5 -9 12 0 0 1 C
   220 -9 12 0 0 1 D
LABELS

   echo "done."
}

plot_map(){
   # plot the profile on a map
   echo -n "add the location... "
   grdimage $area $proj -Ba1f0.5g1WeSn -O -K \
      -C../../gebco/plot/shelf.cpt \
      ../../gebco/plot/gebco_bathy.grd -Y-13 \
      -I../../gebco/plot/gebco_grad.grd \
      >> $outfile
   # add a coastline for the area
   pscoast $area $proj -Ba5f2.5g5WeSn -Df -G0/0/0 -O -K -N1/255/255/255 \
      -W1/255/255/255 >> $outfile
   # add the profile
   psxy ./pointonemin_transect.trk $area $proj -W5/255/255/255 -B0 -O -K \
      >> $outfile
   psxy ./pointonemin_transect.trk $area $proj -W3/0/0/0 -B0 -O -K \
      >> $outfile
   # label the profile start and end
   pstext $area $proj -D0/-0.4 -B0 -O -K -W255/255/255O0.1/255/255/255 \
      << TRANS_LAB >> $outfile
      $slong $slat 10 0 0 1 C
      $elong $elat 10 0 0 1 D
TRANS_LAB

   echo "done."
}

labels(){
   # add a scale bar
   echo -n "add a scale bar... "
   psscale -D7.5/-1.6/13/0.5h -P -C../../gebco/plot/shelf.cpt -O -K -B20:"Depth (m)": >> $outfile
   echo "done."

   # add in the key
   echo -n "add the labels... "
   dist=5.3
   inc=3
   y=15.8

   page=-R0/23/0/33
   a4=-JX23c/33c
   psbasemap $page $a4 -X-3.1 -Y-5.5 -B0 -O -K >> $outfile
   for ((i=0; i<${#grids[@]}; i++)); do
      psxy -V $page $a4 -O -K -B0 -W5/${colours[i]} << LINE >> $outfile
      $dist $y
      $(echo "scale=2; $dist+0.4" | bc -l) $y
LINE
      x_text=$(echo "scale=2; $dist+0.6" | bc -l)
      y_text=$(echo "scale=2; $y-0.11" | bc -l)
      text=$(basename "${grids[i]}" .grd | cut -f1 -d"_" | \
         sed 's/cmap/C-MAP/g;s/seazone/SeaZone/g;s/gebco/GEBCO/g;s/etopo/ETOPO/g;s/britned/BritNed/g')
      pstext $page $a4 -O -K << LABEL >> $outfile
      $x_text $y_text 10 0 0 1 $text
LABEL
      dist=$(echo "scale=2; $dist+$inc" | bc -l)
   done
   echo "done."
}

formats(){
   # convert the images
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress "$outfile" \
      ${outfile%.ps}.pdf
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=${outfile%.ps}.jpg" \
      "$outfile" > /dev/null
   echo "done."
}

mk_transect
plot_profile
plot_map
labels
formats

exit 0
