#!/bin/bash

# script to plot the bathy, radon, DFT and profile results.

gmtset LABEL_FONT_SIZE=22 ANNOT_FONT_SIZE=20
gmtset D_FORMAT=%g PAPER_MEDIA=a4

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 ${1%.*}.pdf
   echo -n "and png... "
   gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.png $1
   echo "done."
}

bathy=./grids/mca_bathy.grd
btrans=../mca_profile_ifft.csv
bheight=../mca_heights.csv
basymm=../mca_asymmetry.csv
grad=${bathy%.*}_grad.grd
cpt=./cpts/$(basename ${bathy%.*}.cpt)

rin=../mca_radon.csv
rinres=${rin%.*}_result.csv
rinstd=${rin%.*}_stddev.csv
rgres=-I0.1/1

fgrd=./grids/mca_fft.grd
fcpt=./cpts/mca_fft.cpt

outfile=./images/combo_mca.ps

barea=$(grdinfo -I1 $bathy)
bproj=-Jx0.018

rarea=-R0/180/-270/270
rsarea=$(minmax -I1 $rinstd)
rproj=-JX13.5/6

farea=-R-0.2/0.2/-0.2/0.2
fproj=-JX6/7.5
fphi=61.12 # normal to crest
flambda=10.08

tarea=$(cut -f3,4 -d, $btrans | minmax -I5/0.2)
tproj=-JX13.5/5

# bathy
plot_bathy(){
   gmtset D_FORMAT=%.0f
   psbasemap -P $barea $bproj -K -X4.4 -Y21.5 \
      -Ba200f50:"Eastings":/a100f50:"Northings":WeSn > $outfile
   grdimage $barea $bproj $bathy -I$grad -C$cpt -O -K >> $outfile
   # add in transect lines
   psxy $barea $bproj $btrans -W8/black -O -K >> $outfile
   pstext $barea $bproj -N -O -K -D0.3/0.6 -WwhiteO0,white << TRANS >> $outfile
   $(awk -F, '{print $1,$2}' $btrans | head -n1) 16 0 0 1 L
TRANS
   pstext $barea $bproj -N -O -K -D-0.5/0.3 -WwhiteO0,white << TRANS >> $outfile
   $(awk -F, '{print $1,$2}' $btrans | tail -n1) 16 0 0 1 L'
TRANS
   psscale -D3/-2.3/4/0.25h -C$cpt -I -Ba1f0.5:"Depth (m)": -O -K >> $outfile

}

plot_fft(){
   gmtset D_FORMAT=%g
   psbasemap $farea $fproj -B0 -O -K -X7.5 >> $outfile
   grdimage $farea $fproj $fgrd -C$fcpt -O -K \
      -Ba0.1f0.05:"kx (m@+-1@+)":/a0.1f0.05:"ky (m@+-1@+)":wESn >> $outfile
   echo "0 0 $fphi $(echo "scale=2; 100*$flambda" | bc -l)" | psxy $farea $fproj -SV0/0/0 -O -K -W5 -Gblack >> $outfile
   echo "0 0" | psxy $farea $fproj -Sc$(echo "scale=2; 0.31*$flambda" | bc -l) -O -K -W8 >> $outfile
   psscale -D3/-2.3/4/0.25h -C$fcpt -Ba2000f500:"Power (m)": -O -K >> $outfile
}

process_radon(){
   gmtset D_FORMAT=%g
   xyz2grd $rarea $rgres -G./grids/$(basename ${rin%.*}.grd) $rin
}

plot_profile(){
   gmtset D_FORMAT=%g
   psbasemap $tarea $tproj -X-7.5 -Y-10.5 -O -K \
      -Ba50:"Distance along line (m)":/a0.2:"Height (m)":WeSn >> $outfile
   cut -f3,4 -d, $btrans | psxy $tarea $tproj -W8 -O -K >> $outfile
   cut -f1,8 -d, $bheight | psxy $tarea $tproj -W8,. -O -K >> $outfile
   awk -F, '{print $1,$8*-1}' $bheight | \
   psxy $tarea $tproj -W8,. -O -K >> $outfile
   awk -F, '{if ($3==1) print $1,$2,90,0.18}' $basymm | \
      psxy $tarea $tproj -SV0.1/0.18/0.1 -W2 -Gblack -O -K >> $outfile
   awk -F, '{if ($3==-1) print $1,$2,270,0.18}' $basymm | \
      psxy $tarea $tproj -SV0.1/0.18/0.1 -O -K >> $outfile
   awk -F, '{if ($3==0) print $1,$2,0,0.18}' $basymm | \
      psxy $tarea $tproj -SV0.1/0.18/0.1 -W2 -D0/-0.1 -Ggrey -O -K >> $outfile
   pstext $tarea $tproj -N -O -K -D0.1/0.2 << LABEL >> $outfile
0 $(echo $tarea | cut -f4 -d'/') 16 0 0 1 L
LABEL
   pstext $tarea $tproj -N -O -K -D-0.6/0.2 << LABEL >> $outfile
$(echo $tarea | cut -f2 -d'/') $(echo $tarea | cut -f4 -d'/') 16 0 0 1 L'
LABEL
}

plot_radon(){
   gmtset D_FORMAT=%g
   makecpt $(grdinfo -T1 ./grids/$(basename ${rin%.*}.grd)) \
      -Cgray > ./cpts/$(basename ${rin%.*}.cpt)
   psbasemap $rarea $rproj -Y-8.8 -Ba45f15:"Projected Angle"::,"-@+o@+":/a100f50:"Projected Coordinate":WSn -O -K >> $outfile
   grdimage $rarea $rproj -O -K -C./cpts/$(basename ${rin%.*}.cpt) \
      ./grids/$(basename ${rin%.*}.grd) >> $outfile
   psxy $rarea $rproj -W8black -O -K << RESULT >> $outfile
   $(head -1 $rinres)
   $(tail -1 $rinres)
RESULT
   # add in the standard deviation plot
   psxy $rsarea $rproj -O -W8black,- $rinstd \
      -Ba30f10:,"-@+o@+":/a30f10:"Standard Deviation":E >> $outfile
}



plot_bathy
plot_fft
#process_radon
plot_profile
plot_radon
formats $outfile
