#!/bin/bash

# script to make a surface, interpolate it to fill nans, then cut it up and
# spit out grids of the data to be used in matlab.

indir=../../raw_data/processed_lines
infile=all_lines_blockmedian_1m.txt
prefix=hsb_2005_
gres=-I1
procarea=-R578106/588473/91505/98705
tmparea=-R578105/588473/91505/98705

inc=150 # subsampling size

mksurf(){
      surface $tmparea ${indir}/${infile} $gres -T0.25 -S5 -V \
         -G../grids/${infile%.txt}_surf_5m_interp_tmp.grd
      grdcut $procarea ../grids/${infile%.txt}_surf_5m_interp_tmp.grd \
         -G../grids/${infile%.txt}_surf_5m_interp.grd
      \rm -f ../grids/${infile%.txt}_surf_5m_interp_tmp.grd
}
mkmask(){
   grdmask $procarea ${indir}/${infile} $gres -S10 -N/NaN/1/1 \
      -G../grids/${infile%.*}_10m_mask.grd
}
mkfouriersurf(){
   grdmath ../grids/${infile%.*}_10m_mask.grd ../grids/${infile%.txt}.grd \
      MUL = ../grids/${infile%.*}_10m_interp_clipped.grd
}
cutgrid(){
   while read xline; do
      while read yline; do
         west=$(echo $xline | cut -f1 -d\ )
         east=$(echo $xline | cut -f2 -d\ )
         south=$(echo $yline | cut -f1 -d\ )
         north=$(echo $yline | cut -f2 -d\ )
         area=-R${west}/${east}/${south}/${north}
         suffix=_${west}_${east}_${south}_${north}

         echo -n "working on ./raw_data/${suffix}.txt... "

         if [ ! -d ../grids/cut_domain/$inc/ ]; then
            mkdir -p ../grids/cut_domain/$inc
         fi
         if [ ! -d ./raw_data/cut_domain/$inc/ ]; then
            mkdir -p ./raw_data/cut_domain/$inc
         fi

#         subsample $indir/$infile ${west[i]} ${east[i]} ${south[i]} ${north[i]} \
#            ./raw_data/${prefix}${suffix}.txt
         grdcut $area ../grids/${infile%.txt}_10m_interp_clipped.grd \
            -G../grids/cut_domain/$inc/${prefix}${suffix}.grd
         grd2xyz $area ../grids/cut_domain/$inc/${prefix}${suffix}.grd \
            > ./raw_data/cut_domain/${prefix}${suffix}.txt
         echo "done."
      done < ./vertical_$inc.txt
   done < ./horizontal_$inc.txt
}

mksurf
mkmask
mkfouriersurf
cutgrid
