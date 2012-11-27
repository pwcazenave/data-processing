#!/bin/bash

#years=(1988 1992 1994 1995 2001 2003 2004 2005 2006)
years=(
   2001
   2003
   2004
   2005
   2006
   )
colours=(
   0/0/0
   100/100/100
   0/0/128
   0/191/255
   34/139/34
   200/0/50
   160/32/240
   255/127/36
   188/238/104
   )

gmtset D_FORMAT %g

plot_area=-R0/18/25/50
plot_proj=-JX25/-15

annot=-Ba2.5f0.5g2.5:,-km::"Distance along line":/a2.5f0.5g2.5:,-m::"Depth"::.Seabed\ profiles\ through\ Noord\ Hinder\ for\ "${years[@]}":WeSn

outfile=./images/transect_"${years[1]}"-2006_001.ps

psbasemap $plot_area $plot_proj -Xc -Yc -K "$annot" > "$outfile"

for ((i=0; i<${#years[@]}; i++ )); do

   gmtset D_FORMAT %.2f

   grid=$(\ls ./grids/noordhinder"${years[i]}"*.grd | \
      egrep -v "mask|grad|surface")
   profile=./profiles/transect_"${years[i]}"_001.trk

   touch "$outfile"

   project -C479500/5743500 -E490000/5757500 -G5 -N > $profile
   grdtrack -G$grid $profile -S > ${profile%.trk}.pfl

   gmtset D_FORMAT %.0f
   awk '{print $3/1000,$4}' ${profile%.trk}.pfl | psxy $plot_area $plot_proj \
      -O -K -W"${colours[i]}" >> "$outfile"

done

psbasemap $plot_area $plot_proj -O -Bg5000/g5WeSn >> "$outfile"

formats(){
   # convert the images to jpeg and pdf from postscript
   echo -n "converting "$outfile" to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress "$outfile" \
      "${outfile%.ps}.pdf" 2> /dev/null
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -quiet \
      "-sOutputFile=${outfile%.ps}.jpg" \
      "$outfile"
   echo "done."
}

formats

exit 0

