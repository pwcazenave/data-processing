#!/bin/csh -f

# calculate the difference between the two datasets

grdmath ./cco/cco_beaulieu.bathy.grd ./emu/emu_beaulieu.bathy.grd SUB = ./output/beaulieu_diff.grd
grdmath ./cco/cco_chichester.bathy.grd ./emu/emu_chichester.bathy.grd SUB = ./output/chichester_diff.grd
#grdmath cco_hamble.bathy.grd
grdmath ./cco/cco_iow.bathy.grd ./emu/emu_iow.bathy.grd SUB = ./output/iow_diff.grd
grdmath ./cco/cco_langstone.bathy.grd ./emu/emu_langstone.bathy.grd SUB = ./output/langstone_diff.grd


