#!/bin/bash

# make a grid of the mca west solent bathy for analysis using the fft code
#PATH=/usr/bin:/bin:/nerc/packages/gmt/v4.2.1/bin
#which surface

gmtdefaults -D > .gmtdefaults4

#area=-R598200/610623/5613228/5623984
#proc_area=-R598200/611000/5613228/5624028
#area=-R598200/599200/5613228/5614228
#proc_area=-R598200/599200/5613228/5614228
area=-R598201/618927/5613228/5627356
proc_area=-R598201/618927/5613228/5627356
gres=1
#infile=./raw_data/mca_western_solent_1m_interp_subset.txt
infile=./raw_data/ws_1m_blockmean.txt

app1(){
   xyz2grd $area -I$gres -G./grids/$(basename ${infile%.*}.grd) $infile
}

app2(){
   gmtset D_FORMAT=%g
   surface -V $proc_area -I$gres -T0.25 -G./grids/$(basename ${infile%.*}_surfaced_large.grd) $infile
   grdcut $area ./grids/$(basename ${infile%.*}_surfaced_large.grd) \
      -G./grids/$(basename ${infile%.*}_surfaced.grd) && \
#      rm ./grids/$(basename ${infile%.*}_surfaced_large.grd)
   grdmask $area -I$gres -NNaN/1/1 -S5 $infile -G./grids/$(basename ${infile%.*}_mask.grd)
   grdmath ./grids/$(basename ${infile%.*}_surfaced.grd) \
      ./grids/$(basename ${infile%.*}_mask.grd) MUL = \
      ./grids/$(basename ${infile%.*}.grd)
}

#app1
app2
