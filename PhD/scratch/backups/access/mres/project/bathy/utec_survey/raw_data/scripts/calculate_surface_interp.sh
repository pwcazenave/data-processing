#!/bin/bash

# calculate percentage of data created with surface with a 2m search radius

area=-R578106/588291/91505/98686

# do xyz2grd on all_lines.txt
#xyz2grd -I0.75 $area -G./grids/all_lines_blockmedian_0.75m_xyz2grd.grd \
#   ../../raw_data/processed_lines/all_lines_blockmedian_0.75m.txt

# make a "normal" mask
grdmask $area ./all_lines_blockmedian_0.75m.txt \
   -G./all_lines_blockmedian_0.75m_xyz2grd_mask.grd \
   -S2 -N/NaN/1/1 -I0.75 -V

# multiply the mask by the xyz2grd grid, and then extract all values that are 
# equal to 1 (i.e. not a depth, and not a NaN). The number of 1's divided by 
# the total number of points, multiplied by 100 will give you the percentage
# that have been created with a search value of 2 (-S2) in grdmask
grdmath ./all_lines_blockmedian_0.75m_xyz2grd_mask.grd -V \
   ./all_lines_blockmedian_0.75m_xyz2grd.grd MUL = \
   ./all_lines_blockmedian_0.75m_xyz2grd_mask_total.grd

grd2xyz ./all_lines_blockmedian_0.75m_xyz2grd_mask_total.grd -V | \
   grep \ 1\ > ./total_ones.txt

wc -l < ./total_ones.txt \
   > ./ones.txt
wc -l < ./all_lines_blockmedian_0.75m.txt \
   > ./total.txt


