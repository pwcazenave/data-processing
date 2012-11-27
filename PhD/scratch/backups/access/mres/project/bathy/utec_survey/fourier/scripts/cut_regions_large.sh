#!/bin/bash

# script to cut out a series of regions for use in the 2D Fourier transform
# code in MatLab. Plot these regions too using xyz2grd to see if resolution
# is OK.

# fix labels
gmtset LABEL_FONT_SIZE=18 ANNOT_FONT_SIZE=18

# coordinates
west=(579000 585900 586000 582500 583500)
east=(579750 586700 587000 583400 584300)
south=(97000 96200 97000 93900 95450)
north=(97750 97000 98000 94800 96250)

indir=./raw_data/processed_lines
infile=all_lines_blockmedian_1m.txt
toutfile=./images/hsb_2005_bathy_large_subregions.ps

gres=-I1

prefix=hsb_2005_large_

procarea=-R578106/588473/91505/98705
tarea=-R578106/588291/91505/98686
tproj=-Jx0.0022
sproj=-Jx0.03

mkgrid(){
   xyz2grd $procarea ${indir}/${infile} $gres -G./grids/${infile%.txt}.grd
}

mksurf(){
   if [ $HOST != "nemo" ]; then 
      echo "Needs to be run on nemo."
   else
      surface $procarea ${indir}/${infile} $gres -T0.25 -S1 \
         -G./grids/${infile%.txt}.grd
   fi
}

small_surf(){
   for ((i=0; i<${#west[@]}; i++)); do
      surface -R${west[i]}/${east[i]}/${south[i]}/${north[i]} $gres -T0.25 -S1 \
         -G./grids/${west[i]}/${east[i]}/${south[i]}/${north[i]}_surf.grd

   done
}

overall(){
   makecpt -Cwysiwyg -T-52/-13/1 -Z > ./cpts/hsb.cpt
#   grdgradient ./grids/${infile%.txt}.grd -Nt0.7 -A250 \
#      -G./grids/${infile%.txt}_grad.grd
#   psbasemap $tarea $tproj \
#      -Ba2000f500g1000:"Eastings":/a1000f500g1000:"Northings":WeSn -Xc -Yc -K \
#      > $toutfile
   grdimage $tarea $tproj ./grids/${infile%.txt}.grd -C./cpts/hsb.cpt \
      -I./grids/${infile%.txt}_grad.grd \
      -Ba2000f500g1000:"Eastings":/a1000f500g1000:"Northings":WeSn -Xc -Yc -K \
      > $toutfile
   psscale -D23.3/7/7/0.5 -Ba10f2 -C./cpts/hsb.cpt -O -K \
      >> $toutfile
   pstext $tarea $tproj -O -K -N << DEPTH >> $toutfile
   588500 96700 18 0 0 1 Depth (m)
DEPTH

   # add the locations sampled
   for ((i=0; i<${#west[@]}; i++)); do
      psxy $tarea $tproj -W3/0/0/0 -O -K -L << LOCATIONS >> $toutfile
      ${west[i]} ${south[i]}
      ${east[i]} ${south[i]}
      ${east[i]} ${north[i]}
      ${west[i]} ${north[i]}
LOCATIONS
      x=$(echo "scale=4; ${west[i]}+((${east[i]}-${west[i]})/2)" | bc -l)
      y=$(echo "scale=4; ${south[i]}+((${north[i]}-${south[i]})/2)" | bc -l)
      if [ $i -le 8 ]; then
         pstext $tarea $tproj -O -K -W255/255/255O -D-0.09/-0.12 << LABEL \
            >> $toutfile
         $x $y 10 0 0 1 $(($i+1))
LABEL
      elif [ $i -gt 8 ] && [ $i -lt $((${#west[@]}-1)) ]; then
         pstext $tarea $tproj -O -K -W255/255/255O -D-0.17/-0.12 << LABEL \
            >> $toutfile
         $x $y 10 0 0 1 $(($i+1))
LABEL
      else
         pstext $tarea $tproj -O -W255/255/255O -D-0.17/-0.12 << LABEL \
            >> $toutfile
         $x $y 10 0 0 1 $(($i+1))
LABEL
      fi
   done
}

cutarea(){
   for ((i=0; i<${#west[@]}; i++)); do
      area=-R${west[i]}/${east[i]}/${south[i]}/${north[i]}
      suffix=$(($i+1))_${west[i]}_${east[i]}_${south[i]}_${north[i]}
      
      echo -n "working on ./raw_data/${prefix}${suffix}.txt... "
      
      subsample $indir/$infile ${west[i]} ${east[i]} ${south[i]} ${north[i]} \
         ./raw_data/${prefix}${suffix}.txt
#      grdcut $area ./grids/${infile%.txt}.grd -G./grids/${prefix}${suffix}.grd
#      grd2xyz $area ./grids/${prefix}${suffix}.grd \
#         > ./raw_data/${prefix}${suffix}.txt
      echo "done."
   done
}

mkgrids(){
   # make surfaces of the extracted regions and remove the bed trend to leave 
   # only the bedforms.

   gres=-I0.75

   for sub in ./raw_data/${prefix}*.txt; do
      echo -n "gridding $sub... "
      area=$(minmax -I1 $sub)

      # make a grid
      surface $area $gres $sub -T0.25 \
         -G./grids/regions/$(basename $sub .txt)_surf.grd
      grdmask $area $gres $sub -N/NaN/1/1 -S2 \
         -G./grids/regions/$(basename $sub .txt)_mask.grd
      grdmath ./grids/regions/$(basename $sub .txt)_surf.grd \
         ./grids/regions/$(basename $sub .txt)_mask.grd \
         MUL = ./grids/regions/$(basename $sub .txt).grd
      \rm ./grids/regions/$(basename $sub .txt)_surf.grd \
         ./grids/regions/$(basename $sub .txt)_mask.grd

      # remove a trend
    
#      grdtrend ./grids/regions/$(basename $sub .txt).grd -N5 \
#         -D./grids/regions/$(basename $sub .txt)_residual.grd

      # make surfer compatible grids
      grdreformat ./grids/regions/$(basename $sub .txt).grd \
         ./grids/surfer/$(basename $sub .txt).grd=sf
   
      # make some xyzs
#      grd2xyz ./grids/regions/$(basename $sub .txt)_residual.grd \
#         > ${sub%.txt}_residual.txt
      echo "done."
   done
}

surf2xyz(){
   for i in ./grids/regions/${prefix}*[0-9].grd; do
   echo -n "make a text file of $i... "
      grd2xyz $i > ${i%.grd}.txt
   echo "done."
   done
}

plot(){
   for ((i=0; i<${#west[@]}; i++)); do
      area=-R${west[i]}/${east[i]}/${south[i]}/${north[i]}
      suffix=$(($i+1))_${west[i]}_${east[i]}_${south[i]}_${north[i]}
      outfile=./images/${prefix}${suffix}.ps
      echo -n "plotting ./grids/regions${prefix}${suffix}.grd... "
      grid=./grids/regions/${prefix}${suffix}.grd
      grd2cpt $area $grid -Cwysiwyg > ./cpts/$(basename $grid .grd).cpt
      grdgradient $grid -Nt0.9 -A250 -G${grid%.grd}_grad.grd
      grdimage $area $sproj $grid -C./cpts/hsb.cpt \
         -I${grid%.grd}_grad.grd \
         -Ba200f50g200:Eastings:/a200f50g200:Northings:WeSn \
         -Xc -Yc -K > $outfile
      psscale -D-7/6/7/0.5 -Ba5f1:"Depth (m)": \
         -C./cpts/hsb.cpt -O >> $outfile
#         -C./cpts/$(basename $grid .grd).cpt -O >> $outfile
      echo "done."
   done
}

formats(){
   # convert the images
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $toutfile \
      ${toutfile%.ps}.pdf
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${toutfile%.ps}.jpg $toutfile
   echo "done."
}

lots_format(){
   for i in ./images/hsb_2005_large*.ps; do
      echo -n "converting $i to pdf "
      ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $i ${i%.ps}.pdf
      echo -n "and jpeg... "
      gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
         -sOutputFile=${i%.ps}.jpg $i
      echo "done."
   done
}


#if [ ! -e ./grids/${infile%.txt}.grd ]; then
#   mkgrid
#fi
#if [ ! -e ./grids/${infile%.txt}.grd ]; then
#   mksurf
#fi
overall
#cutarea
#mkgrids
#surf2xyz
#plot
formats
#lots_format

exit 0
