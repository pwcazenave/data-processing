#!/bin/bash

if [[ ! -e ./grids/nan_grid.grd ]]; then
   echo 487075.5 5751183.5 NaN | \
      xyz2grd -R476907/497244/5742154/5760213 -I5000 -G./grids/nan_grid.grd \
      2> /dev/null
fi

for file in *.xyz; do

   gmtset D_FORMAT=%2f COLOR_NAN=128/128/128

   infile=$file
   nan=./grids/nan_grid.grd
   grid=./grids/${infile%.xyz}.grd
   year=${infile:11:4}
   colour=./${infile%.xyz}.cpt
   outfile=./images/${infile%.xyz}.ps
   annot=-Ba5000f2500g5000:"Eastings":/a5000f2500g5000:"Northings"::.Plot\ of\ Noord\ Hinder\ \($year\):WeSn

   #area=$(minmax -I1 -H15 $infile)
   area=-R476907/497244/5742154/5760213
   proj=-Jx0.0007

   #grd2cpt $area -Cwysiwyg $grid > $colour
   makecpt -T25/50/0.01 -Z -I -Cwysiwyg > $colour

   mkgrd(){
      if [[ $year -lt 2000 ]]; then
         # amend tension factor for best interpolation
#         surface $area -H15 -I10 -S50 -T0.25b -G${grid%.grd}_surface.grd \
#         $infile 2>/dev/null
         grdmask $area $infile -G${grid%.grd}_mask.grd -H15 -I10 -N/NaN/1/1 \
            -S50
         grdmath ${grid%.grd}_mask.grd ${grid%.grd}_surface.grd MUL = $grid
#         xyz2grd $area -H15 -I10 -G$grid $infile
      else
#         surface $area -H15 -I5 -S5 -T0.25 -G${grid%.grd}_surface.grd \
#         $infile 2>/dev/null
         grdmask $area $infile -G${grid%.grd}_mask.grd -H15 -I5 -N/NaN/1/1 \
            -S5
         grdmath ${grid%.grd}_mask.grd ${grid%.grd}_surface.grd MUL = $grid
#         xyz2grd $area -H15 -I5 -G$grid $infile
      fi
#      fi
   }

   mkgrad(){
      if [[ ! -e ${grid%.grd}_grad.grd ]]; then
         grdgradient $grid -G${grid%.grd}_grad.grd -Nt0.7 -A210
      fi
   }

   plot(){
      gmtset D_FORMAT %.0f
      grdimage $area $nan -C$colour $proj -P -K -Xc -Yc > $outfile
      grdimage $area $grid -C$colour $proj -P "$annot" -O -K \
         -I${grid%.grd}_grad.grd >> $outfile
      psscale -C$colour -D8.5/-2/7/0.75h -Ba10f5:,-m::"Depth": -O >> $outfile
   }

   formats(){
      # convert the images to jpeg and pdf from postscript
      echo -n "converting $outfile to pdf "
      ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress "$outfile" \
         "${outfile%.ps}.pdf" > /dev/null
      echo -n "and jpeg... "
      gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -quiet \
         "-sOutputFile=${outfile%.ps}.jpg" \
         "$outfile"
      echo "done."
   }

#   mkgrd
#   mkgrad
   plot
   formats

done

exit 0
