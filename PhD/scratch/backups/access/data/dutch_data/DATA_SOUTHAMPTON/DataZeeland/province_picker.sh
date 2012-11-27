#!/bin/bash

# Script to implement Davis (1974)'s province picker, as described
# in Fox and Hayes (1985).

inraw=./raw_data/0541PHydras_04tm07Utm31Ell.txt
infile=0541PHydras_04tm07Utm31Ell.grd
grd=./grids/$infile
outfile=./images/${infile%.grd}_provinces.ps

area=-R545697/549067/5696705/5699788
proj=-Jx0.002
gres=3

gmtdefaults -D > .gmtdefaults4
gmtset D_FORMAT=%g HEADER_FONT_SIZE=14 ANNOT_FONT_SIZE=12 LABEL_FONT_SIZE=12 HEADER_OFFSET=0c LABEL_OFFSET=0c

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
   mean=$(cut -f3 -d, $inraw | sed -n '26,$p' | mean.awk)

   # make a mask
   grdmask $inraw $area -I$gres -G${grd%.grd}_mask.grd -NNaN/1/1 -S5

   # surface, then highpass filter, then mask, then remove filtered
   # from original, leaving only the low frequency signal.
   surface $area -I$gres -T0 -G${grd%.grd}_surfaced.grd $inraw
   grdmath ${grd%.grd}_surfaced.grd $mean SUB \
      = ${grd%.grd}_surfaced.grd2
   mv ${grd%.grd}_surfaced.grd2 ${grd%.grd}_surfaced.grd
   grdgradient -A135/50 -Nt0.7 -G${grd%.grd}_grad.grd ${grd%.grd}_interpolated.grd
   grdfft ${grd%.grd}_surfaced.grd -G${grd%.grd}_surfaced_highpass.grd -F40/-

   # make interpolated bathy from surfaced one
   grdmath ${grd%.grd}_surfaced.grd ${grd%.grd}_mask.grd MUL \
      = ${grd%.grd}_interpolated.grd

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
   grdmath ${grd%.grd}_surfaced_lowpass.grd ABS = ${grd%.grd}_surfaced_abs.grd
   grdmath ${grd%.grd}_surfaced_abs.grd ${grd%.grd}_mask.grd MUL \
      = ${grd%.grd}_abs.grd

   # low pass filter the absolute grid with same filter dimensions
   grdfft ${grd%.grd}_surfaced_abs.grd -F-/40 -G${grd%.grd}_surfaced_provinces.grd

   # clip the province grid
   grdmath ${grd%.grd}_surfaced_provinces.grd ${grd%.grd}_mask.grd MUL \
      = ${grd%.grd}_provinces.grd
}

plot(){
   makecpt -Crainbow -T-5/5/0.1 -Z > ./cpts/${infile%.grd}_filter.cpt
   makecpt -Crainbow -T-25/25/0.1 -Z > ./cpts/${infile%.grd}_fft.cpt
   makecpt -Crainbow -T-20/20/0.1 -Z > ./cpts/${infile%.grd}_provinces.cpt

   gmtset D_FORMAT=%.0f
   # input bathy
   grdimage $area $proj -Ba1000f250g500:"Eastings":/a500f250g500:"Northings":WeSn \
      -B:."Bathymetry": -I${grd%.grd}_grad.grd \
      -C./cpts/${infile%.grd}_fft.cpt -X3 -Y13.5 ${grd%.grd}_interpolated.grd -K > $outfile
   psscale -D3.4/-1.6/3/0.3h -C./cpts/${infile%.grd}_fft.cpt -Ba20f5 -O -K >> $outfile
   # lowpass masked bathy
   grdimage $area $proj -Ba1000f250g500:"Eastings":/f250g500WeSn \
      -B:."Lowpass": \
      -C./cpts/${infile%.grd}_fft.cpt -X8 ${grd%.grd}_lowpass.grd -O -K >> $outfile
   psscale -D3.4/-1.6/3/0.3h -C./cpts/${infile%.grd}_fft.cpt -Ba20f5 -O -K >> $outfile
   # highpass masked bathy
   grdimage $area $proj -Ba1000f250g500:"Eastings":/f500g500WeSn \
      -B:."Highpass": \
      -C./cpts/${infile%.grd}_filter.cpt -X8 ${grd%.grd}_highpass.grd -O -K >> $outfile
   psscale -D3.4/-1.6/3/0.3h -C./cpts/${infile%.grd}_filter.cpt -Ba2f0.5 -O -K >> $outfile
   # absolute of lowpass
   grdimage $area $proj -Ba1000f250g500:"Eastings":/a500f500g500:"Northings":WeSn \
      -B:."Absolute Lowpassed": \
      -C./cpts/${infile%.grd}_fft.cpt -X-16 -Y-10.4 ${grd%.grd}_abs.grd -O -K >> $outfile
   psscale -D3.4/-1.6/3/0.3h -C./cpts/${infile%.grd}_fft.cpt -Ba20f5 -O -K >> $outfile
   # provinces
   grdimage $area $proj -Ba1000f250g500:"Eastings":/f500g500WeSn \
      -B:."Provinces": \
      -C./cpts/${infile%.grd}_fft.cpt -X8 ${grd%.grd}_provinces.grd -O -K >> $outfile
   psscale -D3.4/-1.6/3/0.3h -C./cpts/${infile%.grd}_fft.cpt -Ba10f5 -O -K >> $outfile
   grdcontour $area $proj ${grd%.grd}_provinces.grd -C5 -O >> $outfile
   gmtset D_FORMAT=%g
}

#processing
plot
formats $outfile

