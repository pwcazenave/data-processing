#!/bin/bash

gmtset LABEL_FONT_SIZE=18
gmtset ANNOT_FONT_SIZE=18

#area=-R541794.5/546641.5/5715714/5718262
proj=(-Jx0.0045 -Jx0.0045 -Jx0.0045 -Jx0.0045)
gres=(3 3 2 3)
#infile=./csv/2028pHydras_05tm07_UTM31ell.csv
infiles=(./csv/*.csv)

for ((curr=0; curr<"${#infiles[@]}"; curr++)); do
   gmtset D_FORMAT=%.2f
   area=$(minmax -H1 -I10 "${infiles[curr]}")
   gmtset D_FORMAT=%g
   tmppref=$(basename "${infiles[curr]}")
   pref="${tmppref%.*}"
   unset tmppref
   outfile=./images/"${pref}".ps
   gridpref=./grids/"${pref}"

   mkgrid(){
      xyz2grd $area \
         -I"${gres[curr]}" \
         "${infiles[curr]}" \
         -G"${gridpref}".grd \
         -H1
   }

   mkgrad(){
      grdgradient \
         -Nt0.7 \
         -A250 \
         "${gridpref}".grd \
         -G"${gridpref}"_grad.grd
   }

   mkcpt(){
      makecpt -T-10/45/0.1 > ./cpts/"${pref}".cpt
   }

   mkplot(){
      gmtset D_FORMAT=%.0f
      grdimage \
         $area \
         ${proj[curr]} \
         -Ba1000f250g500:"Eastings":/a500f250g500:"Northings":WeSn \
         -C./cpts/"${pref}".cpt \
         -I"${gridpref}"_grad.grd \
         "${gridpref}".grd \
         -Xc \
         -Yc \
         -Q \
         > "$outfile"
   }

   formats(){
      echo -n "converting $outfile to pdf "
      ps2pdf -dPDFSETTINGS=/prepress -sPAPERSIZE=a4 "$outfile" \
         "${outfile%.ps}.pdf"
      echo -n "and jpeg... "
      gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
         "-sOutputFile="${outfile%.ps}".jpg" \
         "$outfile" > /dev/null
      echo "done."
   }

   mkgrid || exit 11
   mkgrad || exit 12
   mkcpt || exit 13
   mkplot || exit 14
   formats || exit 15

done

exit 0
