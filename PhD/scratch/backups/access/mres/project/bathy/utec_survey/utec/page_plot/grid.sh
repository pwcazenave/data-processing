#! /bin/csh

# set some variables:
set area_processing=-R578106/588290/91506/98686
set area_plot=-R578117/588284/91508/98686
set proj_plot=-JX26/18
set outfile=../../images/page_plot_bathy.ps

# plot a grid of the surface:
grdimage $area_processing $proj_plot -I../utec_grad.grd ../utec_mask.grd -Ba1000f500g500/a1000f500g500WeSn -C../utec.cpt -X3 -Yc > $outfile
#grdimage $area_processing $proj_plot -I../qinsy/qinsy_grad.grd ../qinsy/qinsy.grd -Ba1000f500g500/a1000f500g500WeSn -C../utec/utec.cpt -X3 -Yc > $outfile
# view the image:
gs -sPAPERSIZE=a4 $outfile
