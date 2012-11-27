#!/bin/bash

# script to plot the difference grids for the unknown wreck for the 4 good
# datasets

infiles=()

west=330486
east=331608
south=5623743
north=5624754

area=-R$west/$east/$south/$north
plot_area=-R330500/331400/5623743/5624400
proj=-Jx0.023
gres=-I1.5

gmtset D_FORMAT=%g LABEL_FONT_SIZE=18 ANNOT_FONT_SIZE=18

#set -x

ssample(){
   # let's have only positive depths, eh? And no gubbins either, thank you.
   for input in ./raw_data/*.txt; do
      grep -v "[a-zA-Z]" $input | tr "," " " | \
         awk '{if ($3<0) print $1,$2,$3*-1; else print $1,$2,$3}' | \
         subsample - $west $east $south $north - > ${input%.txt}.xyz
   done
}

mkgrids(){
   for file in ./raw_data/*.xyz; do
      echo -n "gridding $file... "
      xyz2grd $area $gres $file -G./grids/$(basename $file .xyz).grd
      echo "done."
   done
}

mkdiff(){
   echo -n "make the diff grids... "
   #grdmath ./grids/wessex_arch_awkd.grd \
   #   all_lines_blockmedian_1m.grd SUB = ./grids/2005a-2005b_diff.grd
   grdmath ./grids/wessex_arch_awkd.grd \
      ./grids/ez_unknown_wreck.grd SUB = ./grids/2005a-2006_diff.grd
   #grdmath ./grids/all_lines_blockmedian_1m.grd \
   #   ./grids/ez_unknown_wreck.grd SUB = ./grids/2005b-2006_diff.grd
   grdmath ./grids/ez_unknown_wreck.grd \
      ./grids/0863_Hastings_1m_UTMZone31_Aug2007.grd \
      SUB = ./grids/2006-2007_diff.grd
   echo "done."
}

plot(){
   echo -n "plot the images... "
#   makecpt -Cwysiwyg -Z -T-0.5/3.5/0.1 > ./diff.cpt
   grd2cpt $area -Cwysiwyg ./grids/2005a-2006_diff.grd > ./2005a-2006_diff.cpt
   grd2cpt $area -Cwysiwyg ./grids/2006-2007_diff.grd > ./2006-2007_diff.cpt
   gmtset D_FORMAT=%.0f
   #grdimage $area $proj -C./diff.cpt ./grids/2005a-2005b_diff.grd \
   #   > ./images/2005a-2005b_diff.ps
   #grdimage $area $proj -C./diff.cpt ./grids/2005b-2006_diff.grd \
   #   > ./images/2005b-2006_diff.ps
   grdimage $plot_area $proj -C./2005a-2006_diff.cpt \
      ./grids/2005a-2006_diff.grd \
      -Ba200f20g100:Eastings:/a100f20g100:Northings:WeSn -Xc -Yc -K \
      > ./images/2005a-2006_diff.ps
   gmtset D_FORMAT=%g
   psscale -D22.5/7.3/7/0.5 -C./2005a-2006_diff.cpt -Ba0.5f0.1 \
      -O -K >> ./images/2005a-2006_diff.ps
   pstext $plot_area $proj -N -O << LABEL >> ./images/2005a-2006_diff.ps
   331420 5624245 18 0 0 1 Difference (m)
LABEL
   gmtset D_FORMAT=%.0f
   grdimage $plot_area $proj -C./2006-2007_diff.cpt \
      ./grids/2006-2007_diff.grd \
      -Ba200f20g100:Eastings:/a100f20g100:Northings:WeSn -Xc -Yc -K \
      > ./images/2006-2007_diff.ps
   psscale -D22.5/7.3/7/0.5 -C./2006-2007_diff.cpt -Ba0.5f0.1 \
      -O -K >> ./images/2006-2007_diff.ps
   pstext $plot_area $proj -N -O << LABEL >> ./images/2006-2007_diff.ps
   331420 5624245 18 0 0 1 Difference (m)
LABEL
   gmtset D_FORMAT=%g
   echo "done."
}

lots_format(){
   for i in ./images/200?*-200?*_diff.ps; do
      echo -n "converting $i to pdf "
      ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $i ${i%.ps}.pdf
      echo -n "and jpeg... "
      gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
         -sOutputFile=${i%.ps}.jpg $i
      echo "done."
   done
}


#ssample
#mkgrids
#mkdiff
plot
lots_format
