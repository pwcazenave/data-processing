#!/bin/bash
#
# script to calculate the difference grids relative to the new 2007 data for
# area473 east.
#
# everything will be gridded at 2.5 since that's the lowest resolution of all
# the datasets (2006).
#
# so, let's start with the 2006 data, to see if it's the problem.
#

gmtset LABEL_FONT_SIZE 10
gmtset ANNOT_FONT_SIZE 10
gmtset HEADER_FONT_SIZE 14

area=-R314695/320327/5595450/5599120 # the 2007 area (smallest)
proj=-Jx0.0039
outfile=./images/2007-2006.ps

bm() {
   # reblockmedian the 2007 data to 2.5m
   echo -n "reblockmedian the "
   echo -n "2006 data... "
   #blockmedian $area ../2006/swath/raw_data/area473_2006_lines.txt -I2.5 > \
   #   ./grids/area473_2006_lines_2.5m.bmd
   echo -n "2007 data... "
   blockmedian $area ../2007/raw_data/area473_2007_lines_corrected-odn.txt \
      -I2.5 > ./grids/area473_2007_lines_2.5m.bmd
   echo "done."
}

mkmask() {
   # need to make new mask files of the same area for each year
   echo -n "make new mask files... "
   grdmask ./grids/area473_2007_lines_2.5m.bmd -G./grids/2007_mask.grd \
      $area -I2.5 -N/NaN/1/1 -S10
   grdmask ./grids/area473_2006_lines_2.5m.bmd -G./grids/2006_mask.grd \
      $area -I2.5 -N/NaN/1/1 -S10
   echo "done."
}

maskadd() {
   # add the masks together to make a mask of the smallest area
   echo -n "make magic mask... "
   grdmath ./grids/2007_mask.grd ./grids/2006_mask.grd MUL = \
      ./grids/magic_mask.grd
   echo "done."
}

mksurf() {
   # need to regrid the bathy data to the new area
   echo -n "regrid the 2006 "
   surface $area ./grids/area473_2006_lines_2.5m.bmd -I2.5 -T0.25 \
      -G./grids/area473_2006.grd
   echo -n "and 2007 data... "
   surface $area ./grids/area473_2007_lines_2.5m.bmd -I2.5 -T0.25 \
      -G./grids/area473_2007.grd
   echo "done."
}

grd2007=./grids/area473_2007.grd
grd2006=./grids/area473_2006.grd
mm=./grids/magic_mask.grd

clip() {
   # then I need to clip each grid to the magic mask file
   echo -n "clip each grid file with the magic mask... "
   grdmath $grd2007 $mm MUL = ./grids/area473_2007_clipped.grd
   grdmath $grd2006 $mm MUL = ./grids/area473_2006_clipped.grd
   echo "done."
}

grdsub() {
   # and then subtract one grid from the other
   echo -n "subtract the 2006 from the 2007... "
   grdmath ./grids/area473_2007_clipped.grd ./grids/area473_2006_clipped.grd \
      SUB = ./grids/area473_07-06.grd
   echo "done."
}

plot() {
   # plot the image
   echo -n "plot the difference grid... "
   gmtset D_FORMAT %g
   #makecpt -Crainbow -T-4/22/0.1 -I -Z > ./diff.cpt
   #grd2cpt ./grids/area473_07-06.grd -Crainbow $area -L-2/7 -Z > ./diff.cpt
   gmtset D_FORMAT %.0f
   psbasemap $area $proj -Ba1000f500g1000:"Eastings":/a1000f500g1000:"Northings":WeSn -Xc -Yc -K > $outfile
   grdimage $area $proj -Bg1000 -Cdiff.cpt ./grids/area473_07-06.grd -O -K \
      >> $outfile
   gmtset D_FORMAT %g
   psscale -D23.2/6/5/0.5 -B0.5 -Cdiff.cpt -O -K >> $outfile
   pstext $proj $area -O -K -N << TEXT >> $outfile
   320500 5597800 10 0 0 1 Difference (m)
TEXT
   echo "done."
}

formats() {
   echo -n "convert the image to pdf... "
   ps2pdf -dPDFSETTINGS=/prepress -sPAPERSIZE=a4 "$outfile" \
      "${outfile%.ps}.pdf" &> /dev/null
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=${outfile%.ps}.jpg" \
      "$outfile" &> /dev/null
   echo "done."
}

#bm                      # blockmean
#mkmask                  # make masks
#maskadd                 # make magic mask
#mksurf                  # remake the surfaces
#clip                    # clip the surfaces with the masks
#grdsub                  # subtract the grids
plot                    # plot the grids
formats                 # convert the output

exit 0
