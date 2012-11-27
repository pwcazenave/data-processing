#!/bin/bash

# Script to plot bathy and vector subsets of certain areas in the hsb
# and mca results

gmtset PAPER_MEDIA=a4

# hsb
hsbbathy=./grids/all_lines_blockmedian_1m.grd
hsbvectors=../hsb_2005_300m_subset_results.csv

hsbcpt1=./cpts/hsb_subset1.cpt
hsbsub1=${hsbbathy%.*}_sub1.grd
hsb1=./images/hsb_subset_1.ps
hsbarea1=-R579000/582000/95000/97000
hsbproj1=-Jx0.0074

hsbcpt2=./cpts/hsb_subset2.cpt
hsbsub2=${hsbbathy%.*}_sub2.grd
hsb2=./images/hsb_subset_2.ps
hsbarea2=-R585000/586500/95500/97000
hsbproj2=-Jx0.01

# mca
mcabathy=./grids/ws_1m_blockmean.grd
mcavectors=../ws_200m_subset_results_errors.csv

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
#   grdcut $hsbarea1 $hsbbathy -G$hsbsub1
   grdgradient $hsbsub1 -Nt0.1 -E250/50 -G${hsbsub1%.*}_grad.grd
   grdimage $hsbarea1 $hsbproj1 -C$hsbcpt1 -I${hsbsub1%.*}_grad.grd $hsbsub1 \
      -Ba500f100:"Eastings":/a500f100:"Northings":WeSn -Xc -Yc -K > $hsb1
   # add in the vectors
   awk -F, '{if ($3>2) print $1,$2,$4,0.2*$3}' $hsbvectors | \
      psxy $hsbarea1 $hsbproj1 -O -K -SVb0/0/0 -W5/255/255/255 -Gwhite >> $hsb1
   awk -F, '{if ($3>2) print $1,$2}' $hsbvectors | \
      psxy $hsbarea1 $hsbproj1 -O -K -Sc0.1 -Gblack -Wblack >> $hsb1
   # add in a key
   psscale -D23/7.15/5/0.5 -Ba2:"Depth (m)": -I -C$hsbcpt1 -O -K >> $hsb1
   echo "579250 97100 90 10" | awk '{print $1,$2,$3,0.2*$4}' | \
      psxy $hsbarea1 $hsbproj1 -O -K -SVb0/0/0 -W5,black -Gblack -N >> $hsb1
   echo "579250 97100 90 10" | awk '{print $1,$2,$3,0.2*$4}' | \
      psxy $hsbarea1 $hsbproj1 -O -K -SVb0/0/0 -Sc0.1 -W5,black -Gblack -N >> $hsb1
   pstext $hsbarea1 $hsbproj1 -N -O -D0.75/-0.15 -WwhiteO0,white -N << LABEL >> $hsb1
579400 97100 14 0 0 1 10 m wavelength
LABEL
   formats $hsb1
}

# Hastings 2
hsb2(){
   gmtset LABEL_FONT_SIZE=18 ANNOT_FONT_SIZE=18
#   makecpt -T-40/-15/0.1 -Crainbow -Z > $hsbcpt2
   makecpt $(grdinfo -T0.5 $hsbsub2) -Crainbow -Z > $hsbcpt2
#   grdcut $hsbarea2 $hsbbathy -G$hsbsub2
   grdgradient $hsbsub2 -Nt0.1 -E250/50 -G${hsbsub2%.*}_grad.grd
   grdimage $hsbarea2 $hsbproj2 -C$hsbcpt2 -I${hsbsub2%.*}_grad.grd $hsbsub2 \
      -Ba500f100:"Eastings":/a500f100:"Northings":WeSn -Xc -Yc -K > $hsb2
   # add in the vectors
   awk -F, '{if ($3>2) print $1,$2,$4,0.2*$3}' $hsbvectors | \
      psxy $hsbarea2 $hsbproj2 -O -K -SVb0/0/0 -W5/255/255/255 -Gblack >> $hsb2
   awk -F, '{if ($3>2) print $1,$2}' $hsbvectors | \
      psxy $hsbarea2 $hsbproj2 -O -K -Sc0.1 -Gblack -Wblack >> $hsb2
   # add in a key
   psscale -D16/7.5/5/0.5 -Ba5:"Depth (m)": -I -C$hsbcpt2 -O -K >> $hsb2
   echo "585200 97100 90 10" | awk '{print $1,$2,$3,0.2*$4}' | \
   psxy $hsbarea2 $hsbproj2 -O -K -SVb0/0/0 -W5,black -Gblack -N >> $hsb2
   echo "585200 97100 90 10" | awk '{print $1,$2,$3,0.2*$4}' | \
   psxy $hsbarea2 $hsbproj2 -O -K -SVb0/0/0 -Sc0.1 -W5,black -Gblack -N >> $hsb2
   pstext $hsbarea2 $hsbproj2 -O -D0.75/-0.15 -WwhiteO0,white -N << LABEL >> $hsb2
   585300 97100 14 0 0 1 10 m wavelength
LABEL
   formats $hsb2
}

# MCA 1
mca1(){
   gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
   gmtset PAPER_MEDIA=a4

#   makecpt -T5/30/0.1 -Crainbow -Z -I > $mcacpt1
   makecpt $(grdinfo -T0.5 $mcasub1) -I -Crainbow -Z > $mcacpt1
#   grdcut $mcaarea1 $mcabathy -G$mcasub1
   grdgradient $mcasub1 -Nt0.1 -E250/50 -G${mcasub1%.*}_grad.grd
   gmtset D_FORMAT=%.0f
   grdimage $mcaarea1 $mcaproj1 -C$mcacpt1 -I${mcasub1%.*}_grad.grd $mcasub1 \
      -Ba500f100:"Eastings":/a500f100:"Northings":WeSn -Xc -Yc -K > $mca1
   gmtset D_FORMAT=%g
   # add in the vectors
   awk -F, '{if ($3>2) print $1,$2,$4,0.2*$3}' $mcavectors | \
      psxy $mcaarea1 $mcaproj1 -O -K -SVb0/0/0 -W5/255/255/255 -Gwhite >> $mca1
   awk -F, '{if ($3>2) print $1,$2}' $mcavectors | \
      psxy $mcaarea1 $mcaproj1 -O -K -Sc0.1 -Gblack -Wblack >> $mca1
   # add in a key
   psscale -D21.5/6.25/-5/0.5 -Ba5:"Depth (m)": -I -C$mcacpt1 -O -K >> $mca1
   echo "613750 5624580 90 10" | awk '{print $1,$2,$3,0.2*$4}' | \
      psxy $mcaarea1 $mcaproj1 -O -K -SVb0/0/0 -W5,black -Gblack -N >> $mca1
   echo "613750 5624580 90 10" | awk '{print $1,$2,$3,0.2*$4}' | \
      psxy $mcaarea1 $mcaproj1 -O -K -SVb0/0/0 -Sc0.1 -W5,black -Gblack -N >> $mca1
   pstext $mcaarea1 $mcaproj1 -N -O -D0.75/-0.15 -WwhiteO0,white -N << LABEL >> $mca1
613840 5624580 14 0 0 1 10 m wavelength
LABEL
   formats $mca1
}

# MCA 2
mca2(){
   gmtset LABEL_FONT_SIZE=18 ANNOT_FONT_SIZE=18
#   makecpt -T10/20/0.1 -Crainbow -Z -I > $mcacpt2
#   makecpt $(grdinfo -T0.5 $mcasub2) -I -Crainbow -Z > $mcacpt2
   makecpt -T9/17/0.1 -Crainbow -Z -I > $mcacpt2

#   grdcut $mcaarea2 $mcabathy -G$mcasub2
#   grdgradient $mcasub2 -Nt0.1 -E250/50 -G${mcasub2%.*}_grad.grd
   gmtset D_FORMAT=%.0f
   grdimage -P $mcaarea2 $mcaproj2 -C$mcacpt2 -I${mcasub2%.*}_grad.grd $mcasub2 \
      -Ba500f100:"Eastings":/a500f100:"Northings":WeSn -Xc -Yc -K > $mca2
   gmtset D_FORMAT=%g
   # add in the vectors
   awk -F, '{if ($3>2) print $1,$2,$4,0.08*$3}' $mcavectors | \
      psxy $mcaarea2 $mcaproj2 -O -K -SVb0/0/0 -W5/255/255/255 -Gwhite >> $mca2
   awk -F, '{if ($3>2) print $1,$2}' $mcavectors | \
      psxy $mcaarea2 $mcaproj2 -O -K -Sc0.1 -Gblack -Wblack >> $mca2
   # add in a key
   psscale -D14/8/-5/0.5 -Ba2:"Depth (m)": -I -C$mcacpt2 -O -K >> $mca2
   echo "609150 5619500 90 10" | awk '{print $1,$2,$3,0.2*$4}' | \
   psxy $mcaarea2 $mcaproj2 -O -K -SVb0/0/0 -W5,white -Gwhite >> $mca2
   echo "609150 5619500 90 10" | awk '{print $1,$2,$3,0.2*$4}' | \
   psxy $mcaarea2 $mcaproj2 -O -K -SVb0/0/0 -Sc0.1 -W5,black -Gblack >> $mca2
   pstext $mcaarea2 $mcaproj2 -O -D0.75/-0.15 -WwhiteO0,white << LABEL >> $mca2
   609250 5619500 14 0 0 1 10 m wavelength
LABEL
   formats $mca2
}

#hsb1
#hsb2
#mca1
mca2

