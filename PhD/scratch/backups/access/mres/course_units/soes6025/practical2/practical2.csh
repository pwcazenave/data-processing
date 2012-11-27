#! /bin/csh
set outfile=practical2.ps
set gridfile1=grav_resampled_grid.grd
set gridfile2=age.grd
set gridfile3=grav_age.grd
set area=-R-60/-15/0/30
set area2=-R-41/0/20/45
set proj=-Jm1:3.3e7
set proj2=-JOc-21.4727/-19.3453/-17.0/70.0/4
#
#top panel: gravity data from resampled and regridded grav.grd (now grav_resampled_grid.grd)
#makecpt -Cocean -T-263.522/100/10 >! grav_resampled_grid.cpt
makecpt -T-33/50/10 -Z >! grav_resampled_grid.cpt
#plot top panel
psbasemap $area $proj -X1.4 -Y6.05 -B4:."Gravity Field": -P -K >! $outfile
#plot grav_resampled_grid.grd on top panel
grdimage $area $proj -Cgrav_resampled_grid.cpt $gridfile1 -O -K >> $outfile
psscale -D-1.3/3.45/1.5/0.2 -B75 -Cgrav_resampled_grid.cpt -O -K >> $outfile
#add the coastline
pscoast $area $proj -Df -G110/110/110 -O -K >> $outfile
#
#
#bottom panel: age of the seafloor from age.grd
psbasemap $area2 $proj2 -X1 -Y-4.4 -B4:."Gravity Data for seafloor between 20 and 50 Ma.": -P -O -K >> $outfile
#
#clipping age.grd to blank out regions of seafloor between 20 and 50 Ma. old.
grdclip age.grd -Gage_clip.grd -Sa50/NaN -Sb20/NaN
grdclip age_clip.grd -Gage_clip_fin.grd -Sa20/1.0 -Sb50/1.0
grdmath $area grav_resampled_grid.grd age_clip_fin.grd MUL = grav_age.grd
#
#makecpt: for original age.grd file (not clipped and multiplied)
#makecpt -Chaxby -T0.0263965/179.954/2 >! age.cpt
#
#makecpt: for grav_age.grd clipped and multiplied age.grd and grav.grd
#makecpt -T-100.039/167.625/0.1 >! grav_age.cpt
makecpt -T-30/20/0.1 >! grav_age.cpt
#
#plot age.grd on bottom panel
#grdimage $area2 $proj2 -Cage.cpt $gridfile2 -O -K >> $outfile
#
#plot grav_age.grd on bottom panel
grdimage $area2 $proj2 -Cgrav_age.cpt $gridfile3 -O -K >> $outfile
#plot contour from age.grd
grdcontour $proj2 $area2 -C5 -A10 $gridfile2 -O >> $outfile
#
#output file
gs practical2.ps
