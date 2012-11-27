#!/bin/bash

# script to make gradient and aspect plots for all the subregions

mk_slope_aspect(){
   for sub in ./grids/regions/hsb*[0-9].grd; do
      echo -n "working on $sub... "
      area=$(minmax -I10 ./raw_data/$(basename $sub .grd).txt)
      proj=-Jx0.03
      s_outfile=./images/$(basename $sub .grd)_slope.ps
      a_outfile=./images/$(basename $sub .grd)_aspect.ps

      mkgrad(){
         grdgradient -Dc -S${sub%.grd}_slope.grd -G${sub%.grd}_aspect.grd $sub
         grdmath ${sub%.grd}_slope.grd ATAN 57.295577951 MUL = \
            ${sub%.grd}_deg.grd
         }

#      mkgrad

      grd2cpt $area ${sub%.grd}_aspect.grd -Crainbow -L0/360 -Z \
         > ./cpts/$(basename $sub .grd)_dir.cpt
      grd2cpt $area ${sub%.grd}_deg.grd -Crainbow -Z \
         > ./cpts/$(basename $sub .grd)_slope.cpt
      grdimage $proj $area \
         -Ba200f100g200:"Eastings":/a200f100g200:"Northings":WeSn \
         -C./cpts/$(basename $sub .grd)_dir.cpt ${sub%.grd}_aspect.grd \
         -K -Xc -Yc > $a_outfile
      psscale -D-7/6/7/0.5 -Ba90f45:"Direction (@+o@+)": \
         -C./cpts/$(basename $sub .grd)_dir.cpt -O \
         >> $a_outfile
      grdimage $proj $area \
         -Ba200f100g200:"Eastings":/a200f100g200:"Northings":WeSn \
         -C./cpts/$(basename $sub .grd)_slope.cpt ${sub%.grd}_deg.grd \
         -K -Xc -Yc > $s_outfile
      psscale -D-7/6/7/0.5 -Ba5f1:"Slope (@+o@+)": \
         -C./cpts/$(basename $sub .grd)_slope.cpt -O \
         >> $s_outfile

      # do the histograms
      dir_area=-R0/360/0/0.5
      slope_area=-R0/20/0/30
      h_proj=-JX24/16
      s_histogram=./images/$(basename $sub .grd)_histogram_slope.ps
      a_histogram=./images/$(basename $sub .grd)_histogram_aspect.ps

      mkxyz(){
         grd2xyz ${sub%.grd}_deg.grd -S \
            > ./raw_data/slope_analysis/$(basename ${sub%.grd}_deg).txt
         grd2xyz ${sub%.grd}_aspect.grd -S \
            > ./raw_data/slope_analysis/$(basename ${sub%.grd}_aspect).txt
      }

#      mkxyz

      pshistogram $dir_area $h_proj -W0.5 -G100/100/100 -L0/0/0 \
         -Ba90f45g90:,-"@+o@+"::"Aspect":/a0.1f0.025g0.1:,-%:WeSn \
         ./raw_data/slope_analysis/$(basename ${sub%.grd}_aspect).txt \
         -T2 -Z1 -X3.5 -Yc > $a_histogram
      pshistogram $slope_area $h_proj -W0.57 -G100/100/100 -L0/0/0 \
         -Ba2f0.5g2:,-"@+o@+"::"Slope":/a5f1g5:,-%:WeSn \
         ./raw_data/slope_analysis/$(basename ${sub%.grd}_deg).txt \
         -T2 -Z1 -X3.5 -Yc > $s_histogram
      echo "done."

   done 
}

lots_format(){
   for i in ./images/{hsb*slope.ps,hsb*aspect.ps}; do
      echo -n "converting $i to pdf "
#      ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $i ${i%.ps}.pdf
      echo -n "and jpeg... "
      gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
         -sOutputFile=${i%.ps}.jpg $i
      echo "done."
   done
}

mk_slope_aspect
lots_format

exit 0
