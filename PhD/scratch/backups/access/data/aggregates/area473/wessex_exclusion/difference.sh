#!/bin/csh -f

# script to plot the two bathymetry datasets from the exclusion zones survey
# and also from the wessex archaeology survey of the unknown wreck

##----------------------------------------------------------------------------##

# get the basics in
set wa_area=-R330528.26/331194.92/5623912.43/5624284.34
set ez_area=-R330486.28/331608.177/5623743.57/5624753.74
set proj=-Jx0.002

# i/o
set wa_infile=./raw_data/wessex_arch.txt
set ez_infile_shoal=./raw_data/ez_unknown_wreck_shoal.txt
set ez_infile_deep=./raw_data/ez_unknown_wreck_deep.txt
set wa_outfile=./images/wessex_archaeology.ps
set ez_outfile=./images/exclusion_zones.ps

# labelling etc.
gmtset ANNOT_FONT_SIZE 12
gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 14
gmtset ANNOT_FONT_SIZE_SECONDARY 12
gmtset HEADER_OFFSET 0.2c
gmtset D_FORMAT %7.9lg

##----------------------------------------------------------------------------##


