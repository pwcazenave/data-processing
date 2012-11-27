#!/bin/bash

area=-R-15/15/45/65
gres=2.5

gebco=../gebco/gebco08/grids/GEBCO_08_-15_15_45_65_${gres}km.grd # lat/long
cmap=../cmap/grids/cmap_bathy.grd # lat/long
irish=../bodc/random_bathy/grids/1kmdep.grd # lat/long
britned=../britned/britned_bathy_wgs84.grd # lat/long
seazone=../seazone/grids/seazone.grd # lat/long
#hsb=../../mres/project/bathy/utec_survey/utec_mask.grd # british national grid - can't convert to lat/long
#mca=../mca_bathy/grids/ws_1m_blockmean_5m.grd # eastings/northings - can't resample this

formats(){
   if [ $# -eq 0 ]; then
      echo "Not enough inputs."
      echo "Usage: formats file1.ps [file2.ps] ... [filen.ps]"
   fi
   for i in "$@"; do
      echo -n "converting $i to pdf "
      ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $i ${i%.*}.pdf
      echo -n "and png... "
      gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
         -sOutputFile=${i%.ps}.png $i
      echo "done."
   done
}

mkresample(){
   # Need to resample all the grids to the same resolution and domain size
   if [ ! -d ./grids/palaeo ]; then
      mkdir -p ./grids/palaeo
   fi
   for grid in ${gebco} ${cmap} ${irish} ${britned} ${seazone} ${hsb} ${mca}; do
      name=$(basename ${grid})
      echo $name
      cp ${grid} ./grids/palaeo/${name%.*}_${gres}km_orig.grd
      if [ ${name%.*} == "GEBCO_08" ]; then
         grdedit ${area} ./grids/palaeo/${name%.*}_${gres}km_orig.grd
         grdsample -fg -F -I${gres}k ./grids/palaeo/${name%.*}_${gres}km_orig.grd \
            -G./grids/palaeo/${name%.*}_${gres}km.grd
      else
         grdedit ${area} ./grids/palaeo/${name%.*}_${gres}km_orig.grd
         grdsample -F -I${gres}k ./grids/palaeo/${name%.*}_${gres}km_orig.grd \
            -G./grids/palaeo/${name%.*}_${gres}km.grd
      fi
      rm -f ./grids/palaeo/${name%.*}_${gres}km_orig.grd
   done
}

mknewgrids(){
   # First, turn all grids into xyz
   for grid in ${gebco} ${cmap} ${irish} ${britned} ${seazone}; do
      echo -n "Working on ${grid}... "
      grd2xyz -S ${grid} | \
         xyz2grd -F -I${gres}k ${area} \
         -G./grids/palaeo/$(basename ${grid%.*})_${gres}km.grd
      echo "done."
   done
}

mklatlong(){
   # Some grids need converting to lat/long from british national grid or
   # eastings/northings.
   # Eastings and Northings
   grd2xyz -S ${mca} | mapproject $area -Ju30/1 -F -C -I | \
   grd2xyz -S $mca | mapproject $(grdinfo -I0.01 $mca) -I -Jm1 | \
      xyz2grd ${area} -I1e -G./grids/palaeo/$(basename ${mca} .grd)_1m.grd
   grdsample -F ${area} -I${gres}k ./grids/palaeo/$(basename ${mca} .grd)_1m.grd \
      -G./grids/palaeo/$(basename ${mca} .grd)_${gres}km.grd
   # Remove the temporary grid file
   rm -f ./grids/palaeo/$(basename ${mca} .grd)_1m.grd
}

mkfinalgrd(){
   # Using grdmath with AND, create a combo grid with the worst data first,
   # finishing with the best data.
   # Make a dummy grid with NaNs
   dummy=./grids/palaeo/final.grd
   xyz2grd -F ${area} -I${gres}k -G${dummy} << XYZ
0 0 NaN
XYZ
#   grdmath ./grids/palaeo/${mca}_${gres}km.grd ${dummy} AND = ${dummy}
   grdmath ./grids/palaeo/$(basename ${gebco%.*}_${gres})km.grd ${dummy} AND = ${dummy}
   grdmath ./grids/palaeo/$(basename ${cmap%.*}_${gres})km.grd ${dummy} AND = ${dummy}
   grdmath ./grids/palaeo/$(basename ${irish%.*}_${gres})km.grd ${dummy} AND = ${dummy}
   grdmath ./grids/palaeo/$(basename ${britned%.*}_${gres})km.grd ${dummy} AND = ${dummy}
   grdmath ./grids/palaeo/$(basename ${seazone%.*})_${gres}km.grd ${dummy} AND = ${dummy}
}

plot(){
   dummy=./grids/palaeo/final.grd
   rm -f ./images/final.*
   makecpt -T-500/0/10 -Crainbow > ./shelf.cpt
   grdimage ${area} -Jm0.5 ${dummy} -C./shelf.cpt -Xc -Yc -P -B5WeSn > ./images/final.ps
   grdimage ${area} -Jm0.5 ${gebco} -C./shelf.cpt -Xc -Yc -P -B5WeSn > ./images/gebco_only.ps
   formats ./images/final.ps ./images/gebco_only.ps
}

#mkresample
#mknewgrids
##mklatlong
#mkfinalgrd
plot
