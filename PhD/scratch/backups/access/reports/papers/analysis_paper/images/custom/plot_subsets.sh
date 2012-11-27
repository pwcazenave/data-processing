#!/bin/bash

# Script to plot bathy and vector subsets of certain areas in the hsb
# and mca results

gmtset PAPER_MEDIA=a4

# hsb
hsbbathy=./grids/all_lines_blockmedian_1m.grd
hsbvectors=./raw_data/hsb_300m_subset_results_errors_asymm.csv

hsbcpt1=./cpts/hsb_subset1.cpt
hsbsub1=${hsbbathy%.*}_sub1.grd
hsb1=./images/hsb_subset_1.ps
hsbarea2=-R585000/586500/95500/97000
hsbarea1=-R579000/582000/95000/97000
hsbproj1=-Jx0.0074

hsbcpt2=./cpts/hsb_subset2.cpt
hsbsub2=${hsbbathy%.*}_sub2.grd
hsb2=./images/hsb_subset_2.ps
hsbarea2=-R584300/586300/95000/96250
hsbproj2=-Jx0.01

# mca
mcabathy=./grids/ws_1m_blockmean.grd
mcavectors=./raw_data/ws_200m_subset_results_errors_asymm.csv

mcacpt1=./cpts/mca_subset1.cpt
mcasub1=${mcabathy%.*}_sub1.grd
mca1=./images/mca_subset_1.ps
mcaarea1=-R613500/615900/5623000/5624500
mcaproj1=-Jx0.0085

mcacpt2=./cpts/mca_subset2.cpt
mcasub2=${mcabathy%.*}_sub2.grd
mca2=./images/mca_subset_2.ps
mcaarea2=-R608000/610000/5619400/5622000
mcaproj2=-Jx0.0065

# area481
a481bathy=./grids/7878_Area481_2m_Jan2009_UTMZone31.grd
a481vectors=./raw_data/area481_500-1500m_subset_results_errors_asymm.csv

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

# Hastings 1
hsb1(){
   gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14 D_FORMAT=%g
   makecpt -T-28/-16/0.1 -Crainbow -Z > $hsbcpt1
   grdcut $hsbarea1 $hsbbathy -G$hsbsub1
   grdgradient $hsbsub1 -Nt0.1 -E250/50 -G${hsbsub1%.*}_grad.grd
   grdimage $hsbarea1 $hsbproj1 -C$hsbcpt1 -I${hsbsub1%.*}_grad.grd $hsbsub1 \
      -Ba500f100:"Eastings":/a500f100:"Northings":WeSn -Xc -Yc -K > $hsb1
   # add in the vectors
   awk -F, '{if ($3>2 && $15==1) print $1,$2,$14,0.08*$3}' $hsbvectors | grep -v NaN | \
      psxy $hsbarea1 $hsbproj1 -O -K -SVb0/0.5/0.25 -W8,white -Gwhite >> $hsb1
   awk -F, '{if ($3>2 && $15==1) print $1,$2,$4+90,1.5}' $hsbvectors | \
      psxy $hsbarea1 $hsbproj1 -O -K -SVb0/0/0 -W8,white -Gwhite >> $hsb1
   # add in a key
   psscale -D23/7.15/5/0.5 -Ba2:"Depth (m)": -I -C$hsbcpt1 -O -K >> $hsb1
   echo "579250 97100 90 20" | awk '{print $1,$2,$3,0.08*$4}' | \
      psxy $hsbarea1 $hsbproj1 -O -K -SVb0/0/0 -W5,black -Gblack -N >> $hsb1
   echo "579250 97100 90 20" | awk '{print $1,$2,$3,0.08*$4}' | \
      psxy $hsbarea1 $hsbproj1 -O -K -SVb0/0/0 -Sc0.1 -W5,black -Gblack -N >> $hsb1
   pstext $hsbarea1 $hsbproj1 -N -O -D0.75/-0.15 -WwhiteO0,white -N << LABEL >> $hsb1
579400 97100 14 0 0 1 20 m wavelength
LABEL
   formats $hsb1
}

# Hastings 2
hsb2(){
   gmtset LABEL_FONT_SIZE=18 ANNOT_FONT_SIZE=18
#   makecpt -T-40/-15/0.1 -Crainbow -Z > $hsbcpt2
   makecpt $(grdinfo -T0.5 $hsbsub2) -Crainbow -Z > $hsbcpt2
   grdcut $hsbarea2 $hsbbathy -G$hsbsub2
   grdgradient $hsbsub2 -Nt0.1 -E250/50 -G${hsbsub2%.*}_grad.grd
   grdimage $hsbarea2 $hsbproj2 -C$hsbcpt2 -I${hsbsub2%.*}_grad.grd $hsbsub2 \
      -Ba500f100:"Eastings":/a500f100:"Northings":WeSn -Xc -Yc -K > $hsb2
   # add in the vectors
   awk -F, '{if ($3>2) print $1,$2,$14,0.15*$3}' $hsbvectors | grep -v NaN | \
      psxy $hsbarea2 $hsbproj2 -O -K -SVb0/0.5/0.25 -W8,white -Gwhite >> $hsb2
   awk -F, '{if ($3>2) print $1,$2,$4+90,1.5}' $hsbvectors | \
      psxy $hsbarea2 $hsbproj2 -O -K -SVb0/0/0 -W8,white -Gwhite >> $hsb2
   # add in a key
   psscale -D21/6.5/5/0.5 -Ba5:"Depth (m)": -I -C$hsbcpt2 -O -K >> $hsb2
   echo "585200 96300 90 10" | awk '{print $1,$2,$3,0.15*$4}' | \
   psxy $hsbarea2 $hsbproj2 -O -K -SVb0/0/0 -W5,black -Gblack -N >> $hsb2
   echo "585200 96300 90 10" | awk '{print $1,$2,$3,0.15*$4}' | \
   pstext $hsbarea2 $hsbproj2 -O -D0.75/-0.15 -WwhiteO0,white -N << LABEL >> $hsb2
   585300 96300 14 0 0 1 10 m wavelength
LABEL
   formats $hsb2
}

# MCA 1
mca1(){
   gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
   gmtset PAPER_MEDIA=a4

   grdcut $mcaarea1 $mcabathy -G$mcasub1

#   makecpt -T5/30/0.1 -Crainbow -Z -I > $mcacpt1
   makecpt $(grdinfo -T0.5 $mcasub1) -I -Crainbow -Z > $mcacpt1
   grdcut $mcaarea1 $mcabathy -G$mcasub1
   grdgradient $mcasub1 -Nt0.1 -E250/50 -G${mcasub1%.*}_grad.grd
   gmtset D_FORMAT=%.0f
   grdimage $mcaarea1 $mcaproj1 -C$mcacpt1 -I${mcasub1%.*}_grad.grd $mcasub1 \
      -Ba500f100:"Eastings":/a500f100:"Northings":WeSn -Xc -Yc -K > $mca1
   gmtset D_FORMAT=%g
   # add in the vectors
   awk -F, '{if ($3>2 && $15==1) print $1,$2,$14,0.18*$3}' $mcavectors | grep -v NaN | \
      psxy $mcaarea1 $mcaproj1 -O -K -SVb0/0.4/0.2 -W8,white -Gwhite >> $mca1
   awk -F, '{if ($3>2 && $15==1) print $1,$2,$4+90,1.1}' $mcavectors | \
      psxy $mcaarea1 $mcaproj1 -O -K -SVb0/0/0 -W8,white -Gwhite >> $mca1
   # add in a key
   psscale -D21.5/6.25/-5/0.5 -Ba5:"Depth (m)": -I -C$mcacpt1 -O -K >> $mca1
   echo "613750 5624580 90 10" | awk '{print $1,$2,$3,0.18*$4}' | \
      psxy $mcaarea1 $mcaproj1 -O -K -SVb0/0/0 -W5,black -Gblack -N >> $mca1
   echo "613750 5624580 90 10" | awk '{print $1,$2,$3,0.18*$4}' | \
      psxy $mcaarea1 $mcaproj1 -O -K -SVb0/0/0 -Sc0.1 -W5,black -Gblack -N >> $mca1
   pstext $mcaarea1 $mcaproj1 -N -O -D0.75/-0.15 -WwhiteO0,white -N << LABEL >> $mca1
613840 5624580 14 0 0 1 10 m wavelength
LABEL
   formats $mca1
}

# MCA 2
mca2(){
   gmtset LABEL_FONT_SIZE=18 ANNOT_FONT_SIZE=18

#   grdcut $mcaarea2 $mcabathy -G$mcasub2

#   makecpt -T10/20/0.1 -Crainbow -Z -I > $mcacpt2
#   makecpt $(grdinfo -T0.5 $mcasub2) -I -Crainbow -Z > $mcacpt2
   makecpt -T8/17/0.1 -Crainbow -Z -I > $mcacpt2

#   grdgradient $mcasub2 -Nt0.1 -E250/50 -G${mcasub2%.*}_grad.grd
   gmtset D_FORMAT=%.0f
   grdimage -P $mcaarea2 $mcaproj2 -C$mcacpt2 -I${mcasub2%.*}_grad.grd $mcasub2 \
      -Ba500f100:"Eastings":/a500f100:"Northings":WeSn -Xc -Yc -K > $mca2
   gmtset D_FORMAT=%g
   # add in the vectors
   awk -F, '{if ($3>2 && $15==1) print $1,$2,$14,0.1*$3}' $mcavectors | grep -v NaN | \
      psxy $mcaarea2 $mcaproj2 -O -K -SVb0/0.3/0.15 -W8,white -Gwhite >> $mca2
   awk -F, '{if ($3>2 && $15==1) print $1,$2,$4+90,0.9}' $mcavectors | \
      psxy $mcaarea2 $mcaproj2 -O -K -SVb0/0/0 -W8,white -Gwhite >> $mca2
   # add in a key
   psscale -D14/8/-5/0.5 -Ba2:"Depth (m)": -I -C$mcacpt2 -O -K >> $mca2
   echo "609150 5619500 90 10" | awk '{print $1,$2,$3,0.1*$4}' | \
   psxy $mcaarea2 $mcaproj2 -O -K -SVb0/0/0 -W5,white -Gwhite >> $mca2
   echo "609150 5619500 90 10" | awk '{print $1,$2,$3,0.1*$4}' | \
   psxy $mcaarea2 $mcaproj2 -O -K -SVb0/0/0 -Sc0.1 -W5,black -Gblack >> $mca2
   pstext $mcaarea2 $mcaproj2 -O -D0.75/-0.15 -WwhiteO0,white << LABEL >> $mca2
   609250 5619500 14 0 0 1 10 m wavelength
LABEL
   formats $mca2
}

# Area481 1
a481_1(){
   gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
   gmtset PAPER_MEDIA=a4

   grdcut $a481area1 $a481bathy -G$a481sub1
   makecpt -T-25/-10/0.1 -Crainbow -Z > $a481cpt1
#   makecpt $(grdinfo -T5 $a481sub1) -Crainbow -Z > $a481cpt1
   grdgradient $a481sub1 -Nt0.1 -E15/50 -G${a481sub1%.*}_grad.grd
   gmtset D_FORMAT=%.0f
   grdimage -P $a481area1 $a481proj1 -C$a481cpt1 -I${a481sub1%.*}_grad.grd $a481sub1 \
      -Ba500f100:"Eastings":/a500f100:"Northings":WeSn -Xc -Yc -K > $a4811
   gmtset D_FORMAT=%g
   # add in the vectors
   awk -F, '{if ($3>2) print $1,$2,$4+90,0.08*$3}' $a481vectors | \
      psxy $a481area1 $a481proj1 -O -K -SVb0/0/0 -W5,white -Gwhite >> $a4811
   awk -F, '{if ($3>2) print $1,$2}' $a481vectors | \
      psxy $a481area1 $a481proj1 -O -K -Sc0.1 -Gblack -Wblack >> $a4811
   # add in a key
   psscale -D12.5/10/5/0.5 -Ba5:"Depth (m)": -I -C$a481cpt1 -O -K >> $a4811
   echo "613750 5624580 90 10" | awk '{print $1,$2,$3,0.08*$4}' | \
      psxy $a481area1 $a481proj1 -O -K -SVb0/0/0 -W5,black -Gblack -N >> $a4811
   echo "613750 5624580 90 10" | awk '{print $1,$2,$3,0.08*$4}' | \
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
   makecpt -T-30/-15/0.1 -Crainbow -Z > $a481cpt1
#   makecpt $(grdinfo -T5 $a481sub2) -Crainbow -Z > $a481cpt2
   grdgradient $a481sub2 -Nt0.1 -E15/50 -G${a481sub2%.*}_grad.grd
   gmtset D_FORMAT=%.0f
   grdimage -P $a481area2 $a481proj2 -C$a481cpt2 -I${a481sub2%.*}_grad.grd $a481sub2 \
      -Ba500f100:"Eastings":/a500f100:"Northings":WeSn -Xc -Yc -K > $a4812
   gmtset D_FORMAT=%g
   # add in the vectors
   awk -F, '{if ($3>2) print $1,$2,$4+90,0.08*$3}' $a481vectors | \
      psxy $a481area2 $a481proj2 -O -K -SVb0/0/0 -W5,white -Gwhite >> $a4812
   awk -F, '{if ($3>2) print $1,$2}' $a481vectors | \
      psxy $a481area2 $a481proj2 -O -K -Sc0.1 -Gblack -Wblack >> $a4812
   # add in a key
   psscale -D14.5/10/5/0.5 -Ba5:"Depth (m)": -I -C$a481cpt2 -O -K >> $a4812
   echo "613750 5624580 90 10" | awk '{print $1,$2,$3,0.08*$4}' | \
      psxy $a481area2 $a481proj2 -O -K -SVb0/0/0 -W5,black -Gblack -N >> $a4812
   echo "613750 5624580 90 10" | awk '{print $1,$2,$3,0.08*$4}' | \
      psxy $a481area2 $a481proj2 -O -K -SVb0/0/0 -Sc0.1 -W5,black -Gblack -N >> $a4812
   pstext $a481area2 $a481proj2 -N -O -D0.75/-0.15 -WwhiteO0,white -N << LABEL >> $a4812
613840 5624580 14 0 0 1 10 m wavelength
LABEL
   formats $a4812
}

#hsb1
#hsb2
mca1
mca2
#a481_1
#a481_2

