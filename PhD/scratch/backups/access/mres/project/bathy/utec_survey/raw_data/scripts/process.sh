#!/bin/bash

#blockmedian -R578106/588291/91505/98686 -I0.75 -V ./all_lines.txt > ./all_lines_blockmedian_0.75m.txt

surface -R578106/588291/91505/98686 -I0.75 ./all_lines_blockmedian_0.75m.txt -T0.25 -S1 -G./all_lines_blockmedian_0.75m_surface.grd -V 2>&1 | tee surface.log

grdmask ./all_lines_blockmedian_0.75m.txt -G./all_lines_blockmedian_0.75m_mask.grd -I0.75 -N/NaN/1/1 -S2

grdmath ./all_lines_blockmedian_0.75m_mask.grd ./all_lines_blockmedian_0.75m_surface.grd MUL = ./all_lines_blockmedian_0.75m.grd
