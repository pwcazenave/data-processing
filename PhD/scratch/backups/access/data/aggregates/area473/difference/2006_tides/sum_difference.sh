#!/bin/csh -f

# script to check what the two difference grids of the tidally shifted
# bathy look like when they're added. I'm hoping they'll more of less cancel
# one another out.

##----------------------------------------------------------------------------##

# get the basics in
set area=-R314494/322135/5.59553e+06/5.59951e+06
set proj=-Jx0.003

# i/o
set m_infile=./area473_diff_05_06_m1hr.grd
set p_infile=./area473_diff_05_06_p1hr.grd
set outfile=./images/subtracted_difference.ps

# page dimensions etc.
set a4=-R0/32/0/22
set page=-JX32c/22c

# labelling etc.
gmtset ANNOT_FONT_SIZE 12
gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 14
gmtset ANNOT_FONT_SIZE_SECONDARY 12
gmtset HEADER_OFFSET 0.2c
gmtset D_FORMAT %7.9lg

##----------------------------------------------------------------------------##

# add one grid to the other
grdmath $m_infile $p_infile SUB = total_area473.grd

##----------------------------------------------------------------------------##

# make a colour palette file
grd2cpt -Cwysiwyg $area -Z total_area473.grd > .sum.cpt

# plot the damn thing
grdimage $area $proj \
   -Ba1000f500g1000:"Eastings":/a1000f500g1000:"Northings"::."Subtracted difference values for the plus and minus 1 hour bathy":WeSn \
   -C.sum.cpt total_area473.grd -K -Xc -Yc > $outfile

# add in all the gumph
psbasemap $a4 $page -B0 -O -K -X-4 -Y-5 >> $outfile
psscale -B0.5 -C.sum.cpt -D28/10/3/0.4 -O -K >> $outfile
pstext $page $a4 -O << DIFF_05_06 >> $outfile
27.4 12 12 0 0 1 Difference (m)
DIFF_05_06

##----------------------------------------------------------------------------##

# view the image
#gs -sPAPERSIZE=a4 $outfile
#ps2pdf -dOptimize=true -dPDFSETTINGS=/screen -sPAPERSIZE=a4 $outfile
ps2pdf -dOptimize=true -sPAPERSIZE=a4 $outfile

