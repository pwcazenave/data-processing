#!/bin/bash

orig_area=-R578106/588291/91505/98686
area=-R577439/588959/91495/98695
gres=-I1

blockmedian $area $gres ./all_lines.txt -V > ./all_lines_blockmedian_1m.txt

surface $area $gres ./all_lines_blockmedian_1m.txt -T0.25 -S1 -V -G./all_lines_blockmedian_1m_surface.grd 

#grdmask $area ./all_lines_blockmedian_1m.txt -G./all_lines_blockmedian_1m_mask.grd -V $gres -N/NaN/1/1 -S1 

grdmath -V ./all_lines_blockmedian_1m_surface.grd ./all_lines_blockmedian_1m_mask.grd MUL = ./all_lines_blockmedian_1m_big.grd

grdcut -V $orig_area ./all_lines_blockmedian_1m_big.grd \
   -G./all_lines_blockmedian_1m.grd
