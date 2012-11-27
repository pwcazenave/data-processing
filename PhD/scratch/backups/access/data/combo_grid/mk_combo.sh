#!/bin/bash

# script to generate the combo grid file for the whole continental shelf

gmtset LABEL_FONT_SIZE=18 ANNOT_FONT_SIZE=18 PLOT_DEGREE_FORMAT=F

cmap=../cmap/raw_data/corrected_CMAP_bathy.xyz
#gebco=../gebco/gridone/plot/raw_data/grid_two.xyz
gebco=../gebco/gebco08/gebco08_subset.xyz
britned=../britned/raw_data/britned_bathy_wgs84.txt
#seazone=../seazone/Bathy/gridded_bathy/bathy.xyz
seazone=../../modelling/data/bathymetry/raw_data/seazone/bathy_200m_cd2msl_corrected.xyz
irish_sea=../bodc/random_bathy/1kmdep.dat

coarse=15k
fine=2k

area=-R-16/13/43.5/63

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
      > ./raw_data/irish_sea_fixed.txt
   echo "done."
}

mask(){
   # need to remove certain parts of the GEBCO file (that which falls in the
   # CMAP area. Best to use the GridOne.grd file, then mask out the CMAP area.
   echo -n "mask out the cmap area from the gebco grid... "
   grdmask -I0.5m $area -N/1/NaN/NaN $cmap -G./grids/cmap_area_mask.grd
   grdmask -I0.5m $area -N/1/NaN/NaN ./raw_data/irish_sea_fixed.txt \
      -G./grids/irish_area_mask.grd
   grdmath \
      ./grids/grid08_cut.grd \
      ./grids/cmap_area_mask.grd \
      ./grids/irish_area_mask \
      MUL = ./grids/gebco_masked_cmap.grd
   echo "done."
}

mkxyz(){
   echo -n "convert it to xyz... "
   grd2xyz ./grids/gebco_masked_cmap.grd > ./raw_data/gebco_masked_cmap.txt
   echo "done."
}

combi(){
   echo -n "create a single xyz file... "
   cat $cmap $britned $seazone \
      ./raw_data/irish_sea_fixed.txt \
      ./raw_data/gebco_masked_cmap.txt \
      > ./raw_data/all_continental_shelf.txt
   echo "done."
}

fix_res1(){
   echo -n "adjust the resolution for certain areas... "
   awk '{if ($2>=55) print $0}' \
      ./raw_data/all_continental_shelf.txt \
      > ./raw_data/${coarse}_continental_shelf_north.txt
   awk '{if ($1<=-8) print $0}' \
      ./raw_data/all_continental_shelf.txt \
      > ./raw_data/${coarse}_continental_shelf_west.txt
   blockmean $area -I${coarse} \
      ./raw_data/${coarse}_continental_shelf_west.txt \
      ./raw_data/${coarse}_continental_shelf_north.txt \
      > ./raw_data/${coarse}_all_continental_shelf.txt
      \rm ./raw_data/${coarse}_continental_shelf_west.txt \
         ./raw_data/${coarse}_continental_shelf_north.txt
   echo "done."
}

fix_res2(){
   echo -n "fix resolution for certain areas... "
   awk '{if ($1>-8 && $2<=55) print $0}' \
      ./raw_data/all_continental_shelf.txt \
      > ./raw_data/${fine}_continental_shelf.txt
   blockmean $area -I${fine} \
      ./raw_data/${fine}_continental_shelf.txt \
      > ./raw_data/${fine}_all_continental_shelf.txt
      \rm ./raw_data/${fine}_continental_shelf.txt
   echo "done."
}

mksingle(){
   echo -n "make a single file... "
   cat ./raw_data/${coarse}_all_continental_shelf.txt \
      ./raw_data/${fine}_all_continental_shelf.txt \
      > ./raw_data/gridded_all_continental_shelf_${fine}_${coarse}.txt
   echo "done."
}

mkgrid(){
   echo -n "grid it... "
   xyz2grd $area -I${coarse} ./raw_data/${coarse}_all_continental_shelf.txt \
      -G./grids/${coarse}_all_continental_shelf_total.grd
   xyz2grd $area -I${fine} ./raw_data/${fine}_all_continental_shelf.txt \
      -G./grids/${fine}_all_continental_shelf_total.grd
   echo "done."
}

mkmasks(){
   echo -n "clip it... "
   grdlandmask $area -A1000 -G./grids/landmask_${coarse}.grd \
      -I${coarse} -Df -N1/NaN
   grdlandmask $area -A1000 -G./grids/landmask_${fine}.grd \
      -I${fine} -Df -N1/NaN
   grdmath ./grids/${coarse}_all_continental_shelf_total.grd \
      ./grids/landmask_${coarse}.grd MUL = \
      ./grids/${coarse}_all_continental_shelf.grd
   grdmath ./grids/${fine}_all_continental_shelf_total.grd \
      ./grids/landmask_${fine}.grd MUL = \
      ./grids/${fine}_all_continental_shelf.grd
   echo "done."
}

plot(){
   echo -n "plot the images... "
   makecpt -T-500/0/1 -Crainbow > shelf.cpt
   grdimage $area -Jm0.4 ./grids/${coarse}_all_continental_shelf.grd -Ba4WeSn \
      -C./shelf.cpt -Xc -Yc -P -K \
      > ./images/${coarse}_continental_shelf.ps
   grdimage $area -Jm0.4 ./grids/${fine}_all_continental_shelf.grd -Ba4WeSn \
      -C./shelf.cpt -Xc -Yc -P -K \
      > ./images/${fine}_continental_shelf.ps
   grdimage $area -Jm0.4 -P -Ba4WeSn \
      ./grids/${coarse}_all_continental_shelf.grd \
      -C./shelf.cpt -Xc -Yc -K \
      > ./images/continental_shelf.ps
   grdimage -R-8/13/43.5/55 -Jm0.4 \
      ./grids/${fine}_all_continental_shelf.grd \
      -C./shelf.cpt -X3.2c -O -K \
      >> ./images/continental_shelf.ps
   psscale -D12.5/6.5/5/0.5 -Ba100f20:"Depth (m)": -C./shelf.cpt -O \
      >> ./images/${coarse}_continental_shelf.ps
   psscale -D12.5/6.5/5/0.5 -Ba100f20:"Depth (m)": -C./shelf.cpt -O \
      >> ./images/${fine}_continental_shelf.ps
   psscale -D9.3/6.5/5/0.5 -Ba100f20:"Depth (m)": -C./shelf.cpt -O \
      >> ./images/continental_shelf.ps
   echo "done."
}

images(){
   for i in ./images/*.ps; do
      formats $i
   done
}

#fix_irish
#mask
#mkxyz
combi
fix_res1
fix_res2
mksingle
mkgrid
mkmasks
plot
images
