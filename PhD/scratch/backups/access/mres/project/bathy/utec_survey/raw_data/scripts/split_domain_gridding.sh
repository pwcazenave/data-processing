#!/bin/bash

# all the areas
swarea=-R578106/583198.5/91505/95095.5
searea=-R583198.5/588291/91505/95095.5
nwarea=-R578106/583198.5/95095.5/98686
nearea=-R583198.5/588291/95095.5/98686

gres=-I0.75

# the blockmedian works fine on this domain
#blockmedian -R578106/588291/91505/98686 -I0.75 -V ./all_lines.txt > ./all_lines_blockmedian_0.75m.txt

# need to make the surfaces individually
#surface -R578106/588291/91505/98686 -I0.75 ./all_lines_blockmedian_0.75m.txt -T0.25 -S1 -G./all_lines_blockmedian_0.75m_surface.grd
surface $swarea $gres ./all_lines_blockmedian_0.75m.txt -T0.25 -S1 \
   -G./sw_all_lines_blockmedian_0.75m.grd &
surface $searea $gres ./all_lines_blockmedian_0.75m.txt -T0.25 -S1 \
   -G./se_all_lines_blockmedian_0.75m.grd
surface $nwarea $gres ./all_lines_blockmedian_0.75m.txt -T0.25 -S1 \
   -G./nw_all_lines_blockmedian_0.75m.grd &
surface $nearea $gres ./all_lines_blockmedian_0.75m.txt -T0.25 -S1 \
   -G./ne_all_lines_blockmedian_0.75m.grd

# one mask should suffice
grdmask ./all_lines_blockmedian_0.75m.txt -G./all_lines_blockmedian_0.75m_mask.grd -I0.75 -N/NaN/1/1 -S2 -V

# start putting the files together
grdpaste \
   ./sw_all_lines_blockmedian_0.75m.grd \
   ./se_all_lines_blockmedian_0.75m.grd \
   -G./s_all_lines_blockmedian_0.75m.grd -V
grdpaste \
   ./nw_all_lines_blockmedian_0.75m.grd \
   ./ne_all_lines_blockmedian_0.75m.grd \
   -G./n_all_lines_blockmedian_0.75m.grd -V
grdpaste \
   ./n_all_lines_blockmedian_0.75m.grd \
   ./s_all_lines_blockmedian_0.75m.grd \
   -G./all_lines_blockmedian_0.75m_surface.grd -V

# get rid of the extra surface
grdmath ./all_lines_blockmedian_0.75m_mask.grd \
   ./all_lines_blockmedian_0.75m_surface.grd \
   MUL = ./all_lines_blockmedian_0.75m.grd -V
