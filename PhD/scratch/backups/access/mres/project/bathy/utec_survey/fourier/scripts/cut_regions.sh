#!/bin/bash

# script to cut out a series of regions for use in the 2D Fourier transform
# code in MatLab. Plot these regions too using xyz2grd to see if resolution
# is OK.

# fix labels
gmtset LABEL_FONT_SIZE=18 ANNOT_FONT_SIZE=18

# coordinates
west=(580750 582750 585400 586200 586500 584500 586000 583000 583800 583000 584400 579400 582000 581500 581900 583400 586700 587150 582350 579100 579450 585800 578600 583900 582500 581500)
east=(581250 583250 586000 587000 586950 585000 586500 583300 584200 583500 584700 579800 582300 581900 582200 584000 587200 587650 582750 579600 579650 586050 579000 584300 582750 582500)
south=(92750 93850 94000 95150 96750 95500 97000 98000 98050 97200 97500 94600 96150 95600 93250 94400 94600 97100 97150 97000 96000 95125 93000 97300 95150 96000)
north=(93250 94350 94600 95950 97200 96000 97500 98300 98450 97700 97800 95000 96450 96000 93550 95000 95100 97600 97550 97500 96200 95375 93400 97700 95400 97000)

indir=./raw_data/processed_lines
infile=all_lines_blockmedian_1m.txt
toutfile=./images/hsb_2005_bathy.ps

gres=-I1

prefix=hsb_2005_

procarea=-R578106/588473/91505/98705
tarea=-R578106/588291/91505/98686
tproj=-Jx0.0023
sproj=-Jx0.03

mkgrid(){
   xyz2grd $procarea ${indir}/${infile} $gres -G./grids/${infile%.txt}.grd
}

mksurf(){
   echo "Needs to be run on nemo."
   surface $procarea ${indir}/${infile} $gres -T0.25 -S1 \
      -G./grids/${infile%.txt}.grd
}
   
overall(){
   makecpt -Cwysiwyg -T-52/-13/1 -Z > ./cpts/hsb.cpt
   grdgradient ./grids/${infile%.txt}.grd -Nt0.7 -A250 \
      -G./grids/${infile%.txt}_grad.grd
#   psbasemap $tarea $tproj \
#      -Ba1000f500g1000:"Eastings":/a1000f500g1000:"Northings":WeSn -Xc -Yc -K \
#      > $toutfile
   grdimage $tarea $tproj ./grids/${infile%.txt}.grd -C./cpts/hsb.cpt \
      -I./grids/${infile%.txt}_grad.grd \
      -Ba2000f500g1000:"Eastings":/a1000f500g1000:"Northings":WeSn -Xc -Yc -K \
      > $toutfile
   psscale -D10/-3/-7/0.5h -Ba10f2:"Depth (m)": -C./cpts/hsb.cpt -O -K \
      >> $toutfile
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

   for sub in ./raw_data/hsb_*.txt; do
      echo -n "working on $sub... "
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

plot(){
   for ((i=0; i<${#west[@]}; i++)); do
      area=-R${west[i]}/${east[i]}/${south[i]}/${north[i]}
      suffix=$(($i+1))_${west[i]}_${east[i]}_${south[i]}_${north[i]}
      outfile=./images/${prefix}${suffix}.ps
      echo -n "plotting ./grids/regions${prefix}${suffix}.grd... "
      grid=./grids/regions/${prefix}${suffix}.grd
#      grd2cpt $area $grid -Cwysiwyg > ./cpts/$(basename $grid .grd).cpt
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
   for i in ./images/*.ps; do
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
#overall
#cutarea
mkgrids
plot
formats
lots_format

exit 0
