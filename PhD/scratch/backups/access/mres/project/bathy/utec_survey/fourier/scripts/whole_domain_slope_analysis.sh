#!/bin/bash

# script to make gradient and aspect plots for all the subregions

inc=1000

if [ ! -d ./raw_data/entire_domain_split/$inc ]; then
   mkdir ./raw_data/entire_domain_split/$inc
fi
if [ ! -d ./raw_data/entire_domain_split/$inc/slope_analysis ]; then
   mkdir ./raw_data/entire_domain_split/$inc/slope_analysis
fi
if [ ! -d ./raw_data/entire_domain_split/$inc/surfaced_xyz ]; then
   mkdir ./raw_data/entire_domain_split/$inc/surfaced_xyz
fi
if [ ! -d ./cpts/whole_domain/$inc ]; then
   mkdir ./cpts/whole_domain/$inc
fi
if [ ! -d ./grids/whole_domain/$inc ]; then
   mkdir ./grids/whole_domain/$inc
fi
if [ ! -d ./images/whole_domain/$inc ]; then
   mkdir ./images/whole_domain/$inc
fi

mkgrids(){
   gres=-I1
   for sub in ./raw_data/entire_domain_split/$inc/*.txt; do
      if [ -s $sub ]; then
         echo -n "Gridding ${sub##*/}... " 
         area=$(minmax -I1 $sub)

         # make a grid
         surface $area $gres $sub -T0.25 \
            -G./grids/whole_domain/$inc/$(basename $sub .txt)_surf.grd
         grdmask $area $gres $sub -N/NaN/1/1 -S2 \
            -G./grids/whole_domain/$inc/$(basename $sub .txt)_mask.grd
         grdmath ./grids/whole_domain/$inc/$(basename $sub .txt)_surf.grd \
            ./grids/whole_domain/$inc/$(basename $sub .txt)_mask.grd \
            MUL = ./grids/whole_domain/$inc/$(basename $sub .txt).grd
         \rm ./grids/whole_domain/$inc/$(basename $sub .txt)_surf.grd \
            ./grids/whole_domain/$inc/$(basename $sub .txt)_mask.grd
         echo "done."
      else
            echo "${sub##*/} contains no input data; skipping."
      fi
   done
}

mk_slope_aspect(){
   for sub in ./grids/whole_domain/$inc/hsb*[0-9].grd; do
      echo -n "working on $sub... "
      area=$(minmax -I1 ./raw_data/entire_domain_split/$inc/$(basename $sub .grd).txt)
      proj=-Jx0.03
      s_outfile=./images/whole_domain/$inc/$(basename $sub .grd)_slope.ps
      a_outfile=./images/whole_domain/$inc/$(basename $sub .grd)_aspect.ps

      mkgrad(){
         grdgradient -Dc -S${sub%.grd}_slope.grd -G${sub%.grd}_aspect.grd $sub
         grdmath ${sub%.grd}_slope.grd ATAN 57.295577951 MUL = \
            ${sub%.grd}_deg.grd
         }

      mkgrad

      grd2cpt $area ${sub%.grd}_aspect.grd -Crainbow -L0/360 -Z \
         > ./cpts/whole_domain/$inc/$(basename $sub .grd)_dir.cpt
      grd2cpt $area ${sub%.grd}_deg.grd -Crainbow -Z \
         > ./cpts/whole_domain/$inc/$(basename $sub .grd)_slope.cpt
      grdimage $proj $area \
         -Ba200f100g200:"Eastings":/a200f100g200:"Northings":WeSn \
         -C./cpts/whole_domain/$inc/$(basename $sub .grd)_dir.cpt \
         ${sub%.grd}_aspect.grd \
         -K -Xc -Yc > $a_outfile
      psscale -D-7/6/7/0.5 -Ba90f45:"Direction (@+o@+)": \
         -C./cpts/whole_domain/$inc/$(basename $sub .grd)_dir.cpt -O \
         >> $a_outfile
      grdimage $proj $area \
         -Ba200f100g200:"Eastings":/a200f100g200:"Northings":WeSn \
         -C./cpts/whole_domain/$inc/$(basename $sub .grd)_slope.cpt \
         ${sub%.grd}_deg.grd \
         -K -Xc -Yc > $s_outfile
      psscale -D-7/6/7/0.5 -Ba5f1:"Slope (@+o@+)": \
         -C./cpts/whole_domain/$inc/$(basename $sub .grd)_slope.cpt -O \
         >> $s_outfile

      # do the histograms
      dir_area=-R0/360/0/0.5
      slope_area=-R0/20/0/30
      h_proj=-JX24/16
      s_histogram=./images/whole_domain/$inc/$(basename $sub .grd)_histogram_slope.ps
      a_histogram=./images/whole_domain/$inc/$(basename $sub .grd)_histogram_aspect.ps

      mkxyz(){
         grd2xyz ${sub%.grd}_deg.grd -S \
            > ./raw_data/entire_domain_split/$inc/slope_analysis/$(basename ${sub%.grd}_deg).txt
         grd2xyz ${sub%.grd}_aspect.grd -S \
            > ./raw_data/entire_domain_split/$inc/slope_analysis/$(basename ${sub%.grd}_aspect).txt
      }

      mkxyz

      pshistogram $dir_area $h_proj -W0.5 -G100/100/100 -L0/0/0 \
         -Ba45f22.5g45:,-"@+o@+"::"Aspect":/a0.1f0.025g0.1:,-%:WeSn \
         ./raw_data/entire_domain_split/$inc/slope_analysis/$(basename ${sub%.grd}_aspect).txt \
         -T2 -Z1 -X3.5 -Yc > $a_histogram
      pshistogram $slope_area $h_proj -W0.57 -G100/100/100 -L0/0/0 \
         -Ba2f0.5g2:,-"@+o@+"::"Slope":/a5f1g5:,-%:WeSn \
         ./raw_data/entire_domain_split/$inc/slope_analysis/$(basename ${sub%.grd}_deg).txt \
         -T2 -Z1 -X3.5 -Yc > $s_histogram
      echo "done."

   done 
}

mk_surf_xyz(){
   outdir=./raw_data/entire_domain_split/$inc/surfaced_xyz
   for gridded in ./grids/whole_domain/$inc/hsb_2005*[0-9].grd; do
      echo -n "working on $(basename $gridded)... "
      grd2xyz -S $gridded > $outdir/$(basename $gridded .grd).txt
      echo "done."
   done
}

lots_format(){
   for i in ./images/whole_domain/$inc/{hsb*slope.ps,hsb*aspect.ps}; do
      echo -n "converting $i to pdf "
      ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $i ${i%.ps}.pdf
      echo -n "and jpeg... "
      gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
         -sOutputFile=${i%.ps}.jpg $i
      echo "done."
   done
}

#mkgrids
#mk_slope_aspect
#mk_surf_xyz
lots_format

exit 0
