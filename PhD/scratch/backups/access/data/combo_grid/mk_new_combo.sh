#!/bin/bash

# script to generate the combo grid file for the whole continental shelf
#
# Coarse resolution and fine resolution are cgres and fgres respectively.
#
# In order of decreasing quality, the data are as follows:
#       SeaZone
#       BritNed
#       Irish Sea
#       CMAP
#       GEBCO

gmtset LABEL_FONT_SIZE=18 ANNOT_FONT_SIZE=18 PLOT_DEGREE_FORMAT=F

fgres=3k
cgres=15k

# inputs
cmap=../cmap/raw_data/corrected_CMAP_bathy.xyz
gebco=../gebco/gebco08/GEBCO_08.nc
britned=../britned/raw_data/britned_bathy_wgs84.txt
seazone=../seazone/Bathy/gridded_bathy/bathy.xyz
irish_sea=../bodc/random_bathy/1kmdep.dat

# outputs
cmapgrdfine=./grids/new/cmap_${fgres}.grd
gebcogrdfine=./grids/new/gebco08_${fgres}.grd
britnedgrdfine=./grids/new/britned_${fgres}.grd
seazonegrdfine=./grids/new/seazone_${fgres}.grd
irish_seagrdfine=./grids/new/irish_sea_${fgres}.grd

cmapgrdcoarse=./grids/new/cmap_${cgres}.grd
gebcogrdcoarse=./grids/new/gebco08_${cgres}.grd
britnedgrdcoarse=./grids/new/britned_${cgres}.grd
seazonegrdcoarse=./grids/new/seazone_${cgres}.grd
irish_seagrdcoarse=./grids/new/irish_sea_${cgres}.grd

#areafine=-R-8/13/44/55
area=-R-16/13/44/63

set -e # crap out on errors

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 \
      ${1%.ps}.pdf
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.jpg $1
   echo "done."
}

fix_irish(){
   echo -n "remove the erroneous values from the irish sea data... "
   awk '{if ($3 != -99) print $1,$2,$3*-1}' $irish_sea \
      > ./raw_data/new/irish_sea_fixed.txt
   echo "done."
}

mkgebco(){
   echo -n "extract gebco... "
   grdcut -fg $area $gebco -G./grids/new/gebco08.grd
   grdsample -I${cgres} -T ./grids/new/gebco08.grd -G${gebcogrdcoarse}
   grdsample -I${fgres} -T ./grids/new/gebco08.grd -G${gebcogrdfine}
   echo "done."
}

mkcmap(){
   echo -n "gridding $cmap... "
   xyz2grd $area -I${fgres} $cmap -G$cmapgrdfine
   xyz2grd $area -I${cgres} $cmap -G$cmapgrdcoarse
   echo "done."
}

mkirish(){
   echo -n "gridding $irish_sea... "
   xyz2grd $area -I${fgres} ./raw_data/new/irish_sea_fixed.txt -G$irish_seagrdfine
   xyz2grd $area -I${cgres} ./raw_data/new/irish_sea_fixed.txt -G$irish_seagrdcoarse
   echo "done."
}

mkbritned(){
   echo -n "gridding $britned... "
   xyz2grd $area -I${fgres} $britned -G$britnedgrdfine
   xyz2grd $area -I${cgres} $britned -G$britnedgrdcoarse
   echo "done."
}

mkseazone(){
   echo -n "gridding $seazone... "
   xyz2grd $area -I${fgres} $seazone -G$seazonegrdfine
   xyz2grd $area -I${cgres} $seazone -G$seazonegrdcoarse
   echo "done."
}

combi_grids(){
   echo -n "making combi grids: coarse "
   grdmath \
      $gebcogrdcoarse \
      $irish_seagrdcoarse \
      XOR = \
      ./grids/new/tmp_${cgres}1.grd
   grdmath \
      ./grids/new/tmp_${cgres}1.grd \
      $cmapgrdcoarse \
      XOR = \
      ./grids/new/tmp_${cgres}2.grd
   grdmath \
      ./grids/new/tmp_${cgres}2.grd \
      $britnedgrdcoarse \
      XOR = \
      ./grids/new/combo_${cgres}.grd

   echo -n "and fine... "
   grdmath \
      $gebcogrdfine \
      $irish_seagrdfine \
      XOR = \
      ./grids/new/tmp_${fgres}1.grd
   grdmath \
      ./grids/new/tmp_${fgres}1.grd \
      $cmapgrdfine \
      XOR = \
      ./grids/new/tmp_${fgres}2.grd
   grdmath \
      ./grids/new/tmp_${fgres}2.grd \
      $britnedgrdfine \
      XOR = \
      ./grids/new/combo_${fgres}.grd

   # clean up the tmp files
   rm ./grids/new/tmp_{${fgres},${cgres}}?.grd
   echo "done."
}

maskme(){
   echo -n "mask the coarse gebco data with the fine area... "
   grd2xyz -S ./grids/new/combo_${fgres}.grd | \
      grdmask -S${cgres} -I${cgres} $area -NNaN/1/1 \
      -G./grids/new/combo_${fgres}_mask.grd
   echo "done."
   echo -n "apply the mask... "
   grdmath ./grids/new/combo_${cgres}.grd ./grids/new/combo_${fgres}_mask.grd MUL = \
      ./grids/new/combo_${cgres}_masked.grd
   echo "done."
   echo -n "add land masks... "
   grdlandmask $area -A1000 -G./grids/new/landmask_${cgres}.grd \
      -I${cgres} -Df -N1/NaN
   grdlandmask $area -A1000 -G./grids/new/landmask_${fgres}.grd \
      -I${fgres} -Df -N1/NaN
   grdmath ./grids/new/combo_${cgres}_masked.grd ./grids/new/landmask_${cgres}.grd \
      MUL = ./grids/new/combo_masked_${cgres}.grd
   grdmath ./grids/new/combo_${fgres}.grd ./grids/new/landmask_${fgres}.grd \
      MUL = ./grids/new/combo_masked_${fgres}.grd
   echo "done."
}

getascii(){
   echo -n "converting to ascii: coarse "
   grd2xyz -S ./grids/new/combo_masked_${cgres}.grd | \
      awk '{if ($1<-8 || $2>55) print $1,$2,$3}' > \
      ./raw_data/new/combi_ascii_${fgres}_${cgres}.xyz
   echo -n "and fine... "
   grd2xyz -S ./grids/new/combo_masked_${fgres}.grd | \
      awk '{if ($1>-8 && $1<13 && $2>44 && $2<55) print $1,$2,$3}' >> \
      ./raw_data/new/combi_ascii_${fgres}_${cgres}.xyz
   echo "done."
}

getascii2(){
   echo -n "converting to ascii: coarse "
   grd2xyz -S ./grids/new/combo_masked_${cgres}.grd > \
      ./raw_data/new/combi_ascii_${cgres}.xyz
   echo -n "and fine... "
   grd2xyz -S ./grids/new/combo_masked_${fgres}.grd > \
      ./raw_data/new/combi_ascii_${fgres}.xyz
   echo "done."
}

#fix_irish
mkgebco
mkcmap
mkirish
mkbritned
#mkseazone
combi_grids
maskme
getascii
#getascii2
