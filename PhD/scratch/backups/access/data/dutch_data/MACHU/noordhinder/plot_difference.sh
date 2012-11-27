#!/bin/bash

years=(1988 1992 1994 1995 2001 2003 2004 2005 2006)
nan=./grids/nan_grid.grd
#colour=./diff.cpt

#makecpt -Cwysiwyg -T-2/2/0.1 -Z > $colour

for ((i=0; i<$((${#years[@]}-1)); i++)); do

   # <=1995 is 10m grid, >=2001 is 5m, so if currently doing both, skip along
   if [ ! "${years[i]}" -eq "1995" ] && [ ! "${years[i+1]}" -eq "2001" ]; then
      gmtset D_FORMAT %.2f

      outfile=./images/noordhinder_"${years[i]}"-"${years[i+1]}"_diff.ps
      colour=./diff_"${years[i]}"-"${years[i+1]}".cpt

      area=-R476907/497244/5742154/5760213
      proj=-Jx0.0007

      annot=-Ba5000f2500g5000:"Eastings":/a5000f2500g5000:"Northings"::.Plot\ of\ Depth\ Difference\ for\ "${years[i]}"-"${years[i+1]}":WeSn

      mkdiff(){
         if [[ "${years[i]}" -lt 2000 ]]; then
            first=$(\ls ./grids/noordhinder"${years[i]}"*.grd | \
               egrep -v "mask|grad|surface")
            second=$(\ls ./grids/noordhinder"${years[i+1]}"*.grd | \
               egrep -v "mask|grad|surface")
            grdmath $first $second SUB = \
               ./grids/noordhinder_"${years[i]}"-"${years[i+1]}"_diff.grd
         else
            grdmath ./grids/noordhinder"${years[i]}"_???-??.grd \
               ./grids/noordhinder"${years[i+1]}"_???-??.grd \
               SUB = ./grids/noordhinder_"${years[i]}"-"${years[i+1]}"_diff.grd
         fi
      }

      plot(){
         grd2cpt -Cwysiwyg -L-2.5/2.5 $area \
            ./grids/noordhinder_"${years[i]}"-"${years[i+1]}"_diff.grd > $colour
         gmtset D_FORMAT %.0f
         grdimage $area $proj $nan -C$colour -K -Xc -Yc -P "$annot" > $outfile
         grdimage $area $proj -C$colour -O -K \
            ./grids/noordhinder_"${years[i]}"-"${years[i+1]}"_diff.grd >> $outfile
         psscale -C$colour -D7.5/-2/7/0.75h -Ba1f0.5:,-m::"Difference": -O >> $outfile
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


      mkdiff
      plot
      formats

   fi

done

exit 0
