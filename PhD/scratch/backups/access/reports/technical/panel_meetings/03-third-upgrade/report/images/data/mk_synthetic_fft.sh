#!/bin/bash

# script to plot the explanatory fft figures

gmtset ANNOT_FONT_SIZE=18 LABEL_FONT_SIZE=18

area=-R-1/1/-1/1
plotarea=-R-0.2/0.2/-0.2/0.2
proj=-JX14

gres=0.005

infile=./synthetic_frequency.csv
outfile=./synthetic_flat_fft.ps

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q "$1" \
      "${1%.ps}.pdf"
   echo -n "and png... "
   gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.png "$1"
   echo "done."
}

mkgrid(){
   echo -n "make the 2d fft grid... "
   tr "," " " < $infile | xyz2grd $area -I$gres -G${infile%.csv}.grd
   tr "," " " < ${infile%.*}_energy.csv | xyz2grd $area -I$gres -G${infile%.csv}_energy.grd
   echo "done."
}

plot(){
   echo -n "plot all the graphs... "
   makecpt -T0/30000/10 -Z -Cno_green > ./synthetic.cpt
#   makecpt -T1/4.5/0.1 -Q -Z -Cno_green > ./synthetic.cpt
   grdimage $plotarea $proj -Xc -Yc -K \
      -Ba0.1f0.05g0.1:"kx (m@+-1@+)":/a0.1f0.05g0.1:"ky (m@+-1@+)":WeSn \
      ${infile%.csv}.grd -C./synthetic.cpt > $outfile
   psscale -D16/6.5/7/0.5 -C./synthetic.cpt -Ba5000f1000:"Power": -O -K >> $outfile
#   pstext $plotarea $proj -N -O << POWER >> $outfile
#   0.27 0.11 18 0 0 1 Power
#POWER
   echo "done."
}

plot2(){
   echo -n "plot all the graphs... "
   makecpt -T0/17000000000/10000000 -Z -Cno_green > ./synthetic_energy.cpt
#   makecpt -T1/10/0.1 -Q -Z -Cno_green > ./synthetic_energy.cpt
   grdimage $plotarea $proj -Xc -Yc -K \
      -Ba0.1f0.05g0.1:"kx (m@+-1@+)":/a0.1f0.05g0.1:"ky (m@+-1@+)":WeSn \
      ${infile%.csv}_energy.grd -C./synthetic_energy.cpt > ${outfile%.ps}_energy.ps
   gmtset D_FORMAT=%g
   psscale -D16/6.5/7/0.5 -C./synthetic_energy.cpt -Ba5000000000f1000000000:"Energy Spectral Density (m@+2@+)": -O -K >> ${outfile%.ps}_energy.ps
   gmtset D_FORMAT=%g
#   pstext $plotarea $proj -N -O << POWER >> $outfile
#   0.27 0.11 18 0 0 1 Power
#POWER
   echo "done."
}

#dos2unix $infile
mkgrid
plot
plot2
formats $outfile
formats ${outfile%.ps}_energy.ps

#gs $outfile
