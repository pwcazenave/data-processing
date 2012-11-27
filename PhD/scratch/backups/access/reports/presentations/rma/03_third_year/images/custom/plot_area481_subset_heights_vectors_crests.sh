#!/bin/bash

# Script to plot bathy and vector subsets of certain areas in the hsb
# and mca results

gmtset PAPER_MEDIA=a4

# area481
a481bathy=./grids/7878_Area481_2m_Jan2009_UTMZone31.grd
a481vectors=./raw_data/area481_500-1500m_subset_results_errors_asymm.csv
a481vectors3=./raw_data/area481_200m_subset_results_errors_asymm.csv

a481cpt1=./cpts/a481_subset1.cpt
a481sub1=${a481bathy%.*}_sub1.grd
a4811=./images/a481_subset_1_crests.ps
a481area1=-R341130/343270/5902500/5906500
a481proj1=-Jx0.005

a481cpt2=./cpts/a481_subset2.cpt
a481sub2=${a481bathy%.*}_sub2.grd
a4812=./images/a481_subset_2_crests.ps
a481area2=-R344640/346830/5901720/5905000
a481proj2=-Jx0.006

a481cpt3=./cpts/a481_subset3.cpt
a481sub3=${a481bathy%.*}_sub3.grd
a4813=./images/a481_subset_3_crests.ps
a481area3=-R344500/345800/5907500/5909300
a481proj3=-Jx0.01


formats (){
    if [ $# -eq 0 ]; then
        echo "Not enough inputs.";
        echo "Usage: formats file1.ps [file2.ps] ... [filen.ps]";
    fi;
    for i in "$@";
    do
        echo -n "converting $i to pdf ";
        ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $i ${i%.*}.pdf;
        echo -n "and png... ";
        gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q -sOutputFile=${i%.ps}.png $i;
        echo "done.";
    done
}

# Area481 1
a481_1(){
   gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
   gmtset PAPER_MEDIA=a4

   grdcut $a481area1 $a481bathy -G$a481sub1
   makecpt -T-25/-10/0.1 -Crainbow -Z > $a481cpt1
#   makecpt $(grdinfo -T5 $a481sub1) -Crainbow -Z > $a481cpt1
#   grdgradient $a481sub1 -Nt0.1 -E15/50 -G${a481sub1%.*}_grad.grd
   gmtset D_FORMAT=%.0f
   grdimage -P $a481area1 $a481proj1 -C$a481cpt1 -I${a481sub1%.*}_grad.grd $a481sub1 \
      -Ba500f100:"Eastings":/a500f100:"Northings":WeSn -Xc -Yc -K > $a4811
   gmtset D_FORMAT=%g
   # add in the vectors
   awk -F, '{if ($3>2 && $4!="NaN") print $1,$2,$4,2.5}' $a481vectors | \
      psxy $a481area1 $a481proj1 -O -K -SVb0/0/0.1 -W5/255/255/255 -Gwhite >> $a4811
   awk -F, '{if ($3>4 && $4 != "NaN") print $1,$2}' $a481vectors | \
      psxy $a481area3 $a481proj3 -O -K -Sc0.1 -Wblack -Gblack >> $a4811
# add in a key
   psscale -D12.5/10/5/0.5 -Ba5:"Depth (m)": -I -C$a481cpt1 -O -K >> $a4811
   echo "613750 5624580 90 10" | awk '{print $1,$2,$3,0.2*$4}' | \
      psxy $a481area1 $a481proj1 -O -K -SVb0/0/0 -W5,black -Gblack -N >> $a4811
   echo "613750 5624580 90 10" | awk '{print $1,$2,$3,0.2*$4}' | \
      psxy $a481area1 $a481proj1 -O -K -SVb0/0/0 -Sc0.1 -W5,black -Gblack -N >> $a4811
   pstext $a481area1 $a481proj1 -N -O -D0.75/-0.15 -WwhiteO0,white -N << LABEL >> $a4811
613840 5624580 14 0 0 1 10 m wavelength
LABEL
   formats $a4811
}

# Area481 2
a481_2(){
   gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
   gmtset PAPER_MEDIA=a4

   grdcut $a481area2 $a481bathy -G$a481sub2
   makecpt -T-30/-15/0.1 -Crainbow -Z > $a481cpt2
#   makecpt $(grdinfo -T5 $a481sub2) -Crainbow -Z > $a481cpt2
#   grdgradient $a481sub2 -Nt0.1 -E15/50 -G${a481sub2%.*}_grad.grd
   gmtset D_FORMAT=%.0f
   grdimage -P $a481area2 $a481proj2 -C$a481cpt2 -I${a481sub2%.*}_grad.grd $a481sub2 \
      -Ba500f100:"Eastings":/a500f100:"Northings":WeSn -Xc -Yc -K > $a4812
   gmtset D_FORMAT=%g
   # add in the vectors
   awk -F, '{if ($3>4 && $4!="NaN") print $1,$2,$4,2.5}' $a481vectors | \
      psxy $a481area2 $a481proj2 -O -K -SVb0/0/0 -W5/255/255/255 -Gwhite >> $a4812
   awk -F, '{if ($3>4 && $4 != "NaN") print $1,$2}' $a481vectors | \
      psxy $a481area3 $a481proj3 -O -K -Sc0.1 -Wblack -Gblack >> $a4812
   # add in a key
   psscale -D14.5/10/5/0.5 -Ba5:"Depth (m)": -I -C$a481cpt2 -O -K >> $a4812
   echo "613750 5624580 90 10" | awk '{print $1,$2,$3,0.2*$4}' | \
      psxy $a481area2 $a481proj2 -O -K -SVb0/0/0 -W5,black -Gblack -N >> $a4812
   echo "613750 5624580 90 10" | awk '{print $1,$2,$3,0.2*$4}' | \
      psxy $a481area2 $a481proj2 -O -K -SVb0/0/0 -Sc0.1 -W5,black -Gblack -N >> $a4812
   pstext $a481area2 $a481proj2 -N -O -D0.75/-0.15 -WwhiteO0,white -N << LABEL >> $a4812
613840 5624580 14 0 0 1 10 m wavelength
LABEL
   formats $a4812
}

# Area481 3
a481_3(){
   gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
   gmtset PAPER_MEDIA=a4

   grdcut $a481area3 $a481bathy -G$a481sub3
   makecpt -T-35/-19/0.1 -Crainbow -Z > $a481cpt3
#   makecpt $(grdinfo -T5 $a481sub3) -Crainbow -Z > $a481cpt3
   grdgradient $a481sub3 -Nt1.2 -A15 -G${a481sub3%.*}_grad.grd
   gmtset D_FORMAT=%.0f
   grdimage -P $a481area3 $a481proj3 -C$a481cpt3 -I${a481sub3%.*}_grad.grd $a481sub3 \
      -Ba500f100:"Eastings":/a500f100:"Northings":WeSn -Xc -Yc -K > $a4813
   gmtset D_FORMAT=%g
   # add in the vectors
   awk -F, '{if ($3>4 && $4 != "NaN") print $1,$2,$4,1.85}' $a481vectors3 | \
      psxy $a481area3 $a481proj3 -O -K -SVb0/0/0 -W5/255/255/255 -Gwhite >> $a4813
   awk -F, '{if ($3>4 && $4 != "NaN") print $1,$2}' $a481vectors3 | \
      psxy $a481area3 $a481proj3 -O -K -Sc0.1 -Wblack -Gblack >> $a4813
   # add in a key
   psscale -D14.5/10/5/0.5 -Ba5:"Depth (m)": -I -C$a481cpt3 -O -K >> $a4813
   echo "613750 5624580 90 10" | awk '{print $1,$2,$3,0.2*$4}' | \
      psxy $a481area3 $a481proj3 -O -K -SVb0/0/0 -W5,black -Gblack -N >> $a4813
   echo "613750 5624580 90 10" | awk '{print $1,$2,$3,0.2*$4}' | \
      psxy $a481area3 $a481proj3 -O -K -SVb0/0/0 -Sc0.1 -W5,black -Gblack -N >> $a4813
   pstext $a481area3 $a481proj3 -N -O -D0.75/-0.15 -WwhiteO0,white -N << LABEL >> $a4813
613840 5624580 14 0 0 1 10 m wavelength
LABEL
   formats $a4813
}

#a481_1
#a481_2
a481_3

