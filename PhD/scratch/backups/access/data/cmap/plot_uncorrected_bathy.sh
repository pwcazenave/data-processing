#!/bin/bash
#
# script to plot the cmap bathy dave's using in the model
#

gmtset LABEL_FONT_SIZE 18
gmtset ANNOT_FONT_SIZE 18
gmtset PLOT_DATE_FORMAT dd/mm/yyyy
gmtset D_FORMAT %g
gmtset PLOT_DEGREE_FORMAT F

infile=./raw_data/uncorrected_CMAP_bathy.xyz
outfile=./images/cmap_uncorrected_bathy.ps

area=-R-6.15874/4.8305100/48.5044/53.3284
proj=-Jm2
gres=-I1m

makecpt -T-200/10/0.1 -Z -Cwysiwyg > u_cmap.cpt

# make a surface from the raw xyz at 1 minute
xyz2grd $area $gres -G./grids/u_cmap_raw.grd $infile

#surface $area $gres -G./grids/u_cmap_raw.grd $infile

grdmask $infile -G./grids/u_cmap_mask.grd $gres $area -N/NaN/1/1 -S0.1m
grdmath ./grids/u_cmap_raw.grd ./grids/u_cmap_mask.grd MUL = ./grids/u_cmap_bathy.grd

grdgradient ./grids/u_cmap_bathy.grd -G./grids/u_cmap_grad_all.grd -Nt0.7 -E270/50
grdmath ./grids/u_cmap_grad_all.grd ./grids/u_cmap_mask.grd MUL = ./grids/u_cmap_grad.grd

grdimage $area $proj ./grids/u_cmap_bathy.grd -Ba1f0.5g1WeSn -Cu_cmap.cpt -X2 -Yc -K -I./grids/u_cmap_grad.grd > $outfile

pscoast $area $proj -Ba5f2.5g5WeSn -Df -G0/0/0 -O -K -N1/255/255/255 -W1/255/255/255 >> $outfile

psscale -D23.5/6.4/6/0.5 -B20 -C./u_cmap.cpt -O -K >> $outfile
pstext $area $proj -N -O << TEXT >> $outfile
5.53 51.8 16 0 0 1 Depth (m)
TEXT

#echo "making a geotiff... "
#mbgrdtiff -I./grids/u_cmap_bathy.grd -K./grids/u_cmap_grad.grd -Cu_cmap.cpt -O./images/u_cmap_bathy.tif
#echo "done."

# convert the images to jpeg and pdf from postscript
echo -n "converting $outfile to pdf "
ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress "$outfile" "${outfile%.ps}.pdf"
echo -n "and jpeg... "
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
   "-sOutputFile=${outfile%.ps}.jpg" \
   "$outfile" > /dev/null
echo "done."

exit 0
