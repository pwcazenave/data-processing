#!/bin/bash

# script to cut the entire domain into smaller sections

#set -x

inc=10000 # subsampling increment

outfile=./images/cut_points_$inc.ps
if [ ! -d ./images ]; then
   mkdir -p ./images
fi

south=5661790
west=408090
north=6180540
east=783700

xiterations=$(echo "scale=0; ($east-$west)/$inc" | bc -l)
yiterations=$(echo "scale=0; ($north-$south)/$inc" | bc -l)

mkpoints(){
   \rm ./vertical_$inc.txt ./horizontal_$inc.txt

   touch ./vertical_$inc.txt
   for ((y=1; y<=$yiterations; y++)); do
      max_y=$(echo "scale=0; $south+$inc" | bc -l)
      echo $south $max_y >> vertical_$inc.txt
      south=$max_y
   done

   touch ./horizontal_$inc.txt
   for ((x=1; x<=$xiterations; x++)); do
      max_x=$(echo "scale=0; $west+$inc" | bc -l)
      echo $west $max_x >> horizontal_$inc.txt
      west=$max_x
   done

   \rm ./grid_cut_wesn_$inc.txt
   touch ./grid_cut_wesn_$inc.txt
   while read xline; do
      while read yline; do
         echo $xline $yline >> ./grid_cut_wesn_$inc.txt
#         echo $xline $yline | awk '{print $2,$4}' >> ./grid_cut.txt
      done < ./vertical_$inc.txt
   done < ./horizontal_$inc.txt

#   \rm ./horizontal.txt ./vertical.txt
}

dosample(){
#   infile=./raw_data/processed_lines/all_lines_blockmedian_1m.txt
   infile=./NL-data_MACHU-140508.txt
   while read xline; do
      while read yline; do
         west=$(echo $xline | cut -f1 -d\ )
         east=$(echo $xline | cut -f2 -d\ )
         south=$(echo $yline | cut -f1 -d\ )
         north=$(echo $yline | cut -f2 -d\ )
         outdir=./$inc/
         if [ ! -d $outdir ]; then
            mkdir -p $outdir
         fi
         outfile=$outdir/NL_${west}_${east}_${south}_${north}.txt
         subsample $infile $west $east $south $north $outfile
      done < ./vertical_$inc.txt
   done < ./horizontal_$inc.txt
}

plot(){
   area=-R$west/$east/$south/$north
   proj=-Jx0.0023

   grdimage $area $proj ./grids/all_lines_blockmedian_1m.grd -Xc -Yc -K \
      -Ba2000f200g1000:"Eastings":/a1000f200g1000:"Northings":WeSn \
      -I./grids/all_lines_blockmedian_1m_grad.grd -C./cpts/hsb.cpt \
      > $outfile
   psxy $area $proj ./grid_cut_$inc.txt \
      -O -K -G0/0/0 -Sc0.1 >> $outfile
   psscale -D10/-3/-7/0.5h -Ba10f2:"Depth (m)": -C./cpts/hsb.cpt -O \
      >> $outfile
}

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $outfile \
      ${outfile%.ps}.pdf
      echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${outfile%.ps}.jpg $outfile
   echo "done."
}

mkpoints
dosample
#plot
#formats

exit 0
