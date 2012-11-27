#!/bin/bash

# script to plot the bathy, radon, DFT and profile results.

gmtdefaults -D > .gmtdefaults4
gmtset LABEL_FONT_SIZE=16 ANNOT_FONT_SIZE=16
gmtset D_FORMAT=%g PAPER_MEDIA=a4

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 ${outfile%.*}.pdf
   echo -n "and png... "
   gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.png $outfile
   echo "done."
}

bathyin=../synthetic_bathy.csv
bathy=./grids/synthetic_bathy.grd
bres=-I0.5
grad=${bathy%.*}_grad.grd
cpt=./cpts/$(basename ${bathy%.*}.cpt)

rin=../synthetic_radon.csv
rinres=${rin%.*}_result.csv
rinstd=${rin%.*}_stddev.csv
rgres=-I0.1/1

fgrd=./grids/synthetic_fft.grd
fcpt=./cpts/synthetic_fft.cpt
fgres=-I0.005
fin=../synthetic_fft.csv

outfile=./images/combo_synthetic.ps

barea=-R0/200/0/200
bproj=-JX6

rarea=-R0/180/-270/270
rsarea=$(minmax -I1 $rinstd)
rproj=-JX14/6.5

farea=-R-0.2/0.2/-0.2/0.2
fproj=-JX6
fphi=60 # normal to crest
flambda=0.05

# bathy
process_bathy(){
   gmtset D_FORMAT=%g
   xyz2grd $barea $bres -G$bathy $bathyin
}

plot_bathy(){
   makecpt -T-2/2/0.1 -Cgray > ./cpts/$(basename ${bathyin%.*}.cpt)
   gmtset D_FORMAT=%.0f
   psbasemap $barea $bproj -P -K -X3.2 -Y22 \
      -Ba100f50:"Eastings":/a100f50:"Northings":WeSn > $outfile
   grdimage $barea $bproj $bathy -C$cpt -O -K >> $outfile
   psscale -D3/-2.3/4/0.25h -C$cpt -Ba1f0.5:"Depth (m)": -O -K >> $outfile
}

process_fft(){
   xyz2grd $farea $fgres -G$fgrd $fin
}

plot_fft(){
   gmtset D_FORMAT=%g
#   makecpt $(grdinfo -T1 ./grids/$(basename ${fin%.*}.grd)) -I \
#   gmtset COLOR_BACKGROUND=white
   makecpt -T0/50000/100 \
      -Cgray -I > ./cpts/$(basename ${fin%.*}.cpt)
   psbasemap $farea $fproj -B0 -O -K -X8 >> $outfile
   grdimage $farea $fproj $fgrd -C$fcpt -O -K \
      -Ba0.1f0.05:"kx (m@+-1@+)":/a0.1f0.05:"ky (m@+-1@+)":wESn >> $outfile
#   echo "0 0 $fphi $(echo "scale=2; $flambda*100" | bc -l)" | psxy $farea $fproj -SV0/0/0 -O -K -W5,black >> $outfile
#   echo "0 0" | psxy $farea $fproj -Sc$(echo "scale=2; 30*$flambda" | bc -l) -O -K -W8,black >> $outfile
   psscale -D3/-2.3/4/0.25h -C$fcpt -Ba50000f10000:"Power (m)": -O -K >> $outfile
   gmtset COLOR_BACKGROUND=black
}

process_radon(){
   gmtset D_FORMAT=%g
   xyz2grd $rarea $rgres -G./grids/$(basename ${rin%.*}.grd) $rin
}

plot_radon(){
   gmtset D_FORMAT=%g
   makecpt $(grdinfo -T1 ./grids/$(basename ${rin%.*}.grd)) \
      -Cgray > ./cpts/$(basename ${rin%.*}.cpt)
   psbasemap $rarea $rproj -X-8 -Y-11.7 -Ba45f15:"Projected Angle"::,"-@+o@+":/a100f50:"Projected Coordinate":WSn -O -K >> $outfile
   grdimage $rarea $rproj -O -K -C./cpts/$(basename ${rin%.*}.cpt) \
      ./grids/$(basename ${rin%.*}.grd) >> $outfile
   psxy $rarea $rproj -W8black -O -K << RESULT >> $outfile
   $(head -1 $rinres)
   $(tail -1 $rinres)
RESULT
   # add in the standard deviation plot
   psxy $rsarea $rproj -O -W8black,- $rinstd \
      -Ba30f10:,"-@+o@+":/a100f50:"Standard Deviation":E >> $outfile
}

process_bathy
plot_bathy
process_fft
plot_fft
process_radon
plot_radon
formats $outfile
