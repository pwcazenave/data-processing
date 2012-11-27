#!/bin/bash

# script to take the irregularly sampled data I made of the sediment distribution
# over the uk continental shelf (based largely on the BGS map, but also on Vaslet
# et al.'s map).

infile=./bgs_grain_size.xyz
area=-R-15.5/13/44/63
gres=5000e
verbose="-V"

blockmean $verbose $area -I$gres $infile > ${infile%.*}_${gres/e/m}_blkmean.xyz
xyz2grd $verbose $area -I$gres ${infile%.*}_${gres/e/m}_blkmean.xyz \
   -G${infile%.*}_${gres/e/m}_blkmean.grd
#surface -T1 $verbose $area -I$gres ${infile%.*}_${gres/e/m}_blkmean.xyz -G${infile%.*}_${gres/e/m}_blkmean.grd
grdlandmask $verbose $area -I$gres -A1000 -G${infile%.*}_${gres/e/m}_landmask.grd -Df -N1/NaN
grdmath $verbose ${infile%.*}_${gres/e/m}_landmask.grd \
   ${infile%.*}_${gres/e/m}_blkmean.grd \
   MUL = ${infile%.*}_${gres/e/m}_masked.grd
grd2xyz $verbose -S ${infile%.*}_${gres/e/m}_masked.grd > ${infile%.*}_${gres/e/m}.xyz
