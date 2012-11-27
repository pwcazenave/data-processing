#!/bin/bash

# Script to implement Davis (1974)'s province picker, as described
# in Fox and Hayes (1985).

area=-R578117/588284/91508/98686
proj=-Jx0.00075
proj_single=-Jx0.0021
gres=5
cutoff=200

inraw=../raw_data/processed_lines/lines_blockmeaned_${gres}m.txt
infile=hsb_${gres}m.grd
grd=./grids/$infile
outfile=../images/${infile%.grd}_provinces.ps

set -e

rm ./.gmtdefaults4
gmtdefaults -D > .gmtdefaults4
gmtset HEADER_FONT_SIZE=14 ANNOT_FONT_SIZE=12 LABEL_FONT_SIZE=12 HEADER_OFFSET=0c LABEL_OFFSET=0c

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 ${1%.ps}.pdf
   echo -n "and png... "
   gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.png $outfile
   echo "done."
}

processing(){
   # get the mean of the input data and use to subtract from the surface
   mean=$(cut -f3 $inraw | mean.awk)

   # make a mask
   grdmask $inraw $area -I$gres -G${grd%.grd}_mask.grd -NNaN/1/1 -S5

   # surface, then highpass filter, then mask, then remove filtered 
   # from original, leaving only the low frequency signal.
   surface $area -I$gres -T0 -G${grd%.grd}_surfaced.grd $inraw
   grdmath ${grd%.grd}_surfaced.grd $mean SUB \
      = ${grd%.grd}_surfaced.grd2
   mv ${grd%.grd}_surfaced.grd2 ${grd%.grd}_surfaced.grd
   # make interpolated bathy from surfaced one
   grdmath ${grd%.grd}_surfaced.grd ${grd%.grd}_mask.grd MUL \
      = ${grd%.grd}_interpolated.grd
   grdgradient -A135/50 -Nt0.7 -G${grd%.grd}_grad.grd ${grd%.grd}_interpolated.grd
   grdfft ${grd%.grd}_surfaced.grd -G${grd%.grd}_surfaced_highpass.grd -F$cutoff/-

   # subtract the highpass from the original and apply the mask
   # done as two steps because the second grdfft needs a nan-less grid
   grdmath ${grd%.grd}_surfaced.grd ${grd%.grd}_surfaced_highpass.grd SUB \
      = ${grd%.grd}_surfaced_lowpass.grd
   grdmath ${grd%.grd}_surfaced_lowpass.grd ${grd%.grd}_mask.grd MUL \
      = ${grd%.grd}_lowpass.grd

   # save a highpass filtered bathy which has been masked
   grdmath ${grd%.grd}_surfaced_highpass.grd ${grd%.grd}_mask.grd MUL \
      = ${grd%.grd}_highpass.grd 

   # full-wave rectify by taking absolute of all values
   grdmath ${grd%.grd}_surfaced_highpass.grd ABS = ${grd%.grd}_surfaced_abs.grd 
   grdmath ${grd%.grd}_surfaced_abs.grd ${grd%.grd}_mask.grd MUL \
      = ${grd%.grd}_abs.grd

   # lowpass filter the absolute grid with same filter dimensions
   grdfft ${grd%.grd}_surfaced_abs.grd -F-/$cutoff -G${grd%.grd}_surfaced_provinces.grd

   # clip the province grid
   grdmath ${grd%.grd}_surfaced_provinces.grd ${grd%.grd}_mask.grd MUL \
      = ${grd%.grd}_provinces.grd
}

plot(){
   gmtset D_FORMAT=%g

   makecpt -Crainbow -T-3/4/0.1 > ./cpts/${infile%.grd}_filter.cpt
   makecpt -Crainbow -T-20/20/0.1 > ./cpts/${infile%.grd}_fft.cpt
   makecpt -Crainbow -T-10/10/0.1 > ./cpts/${infile%.grd}_provinces.cpt
   
   # input bathy
   grdimage $area $proj -Ba4000f500g1000:"Eastings":/a2000f500g1000:"Northings":WeSn \
      -B:."Bathymetry": -I${grd%.grd}_grad.grd \
      -C./cpts/${infile%.grd}_fft.cpt -X3 -Y13.5 ${grd%.grd}_interpolated.grd -K > $outfile
   psscale -D3.8/-1.6/3/0.3h -C./cpts/${infile%.grd}_fft.cpt -Ba20f5 -O -K >> $outfile
   # lowpass masked bathy
   grdimage $area $proj -Ba4000f500g1000:"Eastings":/f500g1000WeSn \
      -B:."Lowpass": \
      -C./cpts/${infile%.grd}_fft.cpt -X8.5 ${grd%.grd}_lowpass.grd -O -K >> $outfile
   psscale -D3.8/-1.6/3/0.3h -C./cpts/${infile%.grd}_fft.cpt -Ba20f5 -O -K >> $outfile
   # highpass masked bathy
   grdimage $area $proj -Ba4000f500g1000:"Eastings":/f500g1000WeSn \
      -B:."Highpass": \
      -C./cpts/${infile%.grd}_filter.cpt -X8.5 ${grd%.grd}_highpass.grd -O -K >> $outfile
   psscale -D3.8/-1.6/3/0.3h -C./cpts/${infile%.grd}_filter.cpt -Ba2f0.5 -O -K >> $outfile
   # absolute of lowpass
   grdimage $area $proj -Ba4000f500g1000:"Eastings":/a2000f500g1000:"Northings":WeSn \
      -B:."Absolute Highpassed": \
      -C./cpts/${infile%.grd}_fft.cpt -X-17 -Y-10.4 ${grd%.grd}_abs.grd -O -K >> $outfile
   psscale -D3.8/-1.6/3/0.3h -C./cpts/${infile%.grd}_filter.cpt -Ba2f0.5 -O -K >> $outfile
   # provinces
   grdimage $area $proj -Ba4000f500g1000:"Eastings":/f500g1000WeSn \
      -B:."Provinces": \
      -C./cpts/${infile%.grd}_provinces.cpt -X8.5 ${grd%.grd}_provinces.grd -O -K >> $outfile
   psscale -D3.8/-1.6/3/0.3h -C./cpts/${infile%.grd}_provinces.cpt -Ba5f1 -O -K >> $outfile
   grdcontour $area $proj ${grd%.grd}_provinces.grd -C5 -O -W5 >> $outfile
   formats $outfile
}

single_plot(){
   gmtdefaults -D > .gmtdefaults4
   gmtset HEADER_FONT_SIZE=14 ANNOT_FONT_SIZE=18 LABEL_FONT_SIZE=18
   grdimage $area $proj_single -Ba2000f500:"Eastings":/a1000f500:"Northings":WeSn \
      -C./cpts/${infile%.grd}_provinces.cpt -Xc -Yc ${grd%.grd}_provinces.grd -K > ${outfile%.ps}_single.ps
   psscale -D22.5/7.5/7/0.5 -C./cpts/${infile%.grd}_provinces.cpt -B5 -O -K >> ${outfile%.ps}_single.ps
   grdcontour $area $proj_single ${grd%.grd}_provinces.grd -C10 -W5 -O >> ${outfile%.ps}_single.ps
   formats ${outfile%.ps}_single.ps
}

processing
plot
single_plot

exit 0
