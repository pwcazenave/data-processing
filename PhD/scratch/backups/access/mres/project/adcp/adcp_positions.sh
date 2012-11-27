#! /bin/csh

# script to plot the position of the ADCPs from site 2 and 3 of the utec data on the bathy map

set map_area=-R578117/588284/91508/98686
set map_proj=-Jx0.002
set text_area=-R0/30/0/20
set text_plot=-JX30/20
set outfile=map.ps

gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 16

# add the bathy
psbasemap $map_area $map_proj -Ba2000f1000g500:"Eastings":/a2000f1000g500:"Northings"::."Location of the Deployed ADCPs":WeSn -Xc -Yc -K > $outfile
grdimage $map_area $map_proj -I../bathy/utec_survey/utec/utec_grad.grd -C../bathy/utec_survey/utec/utec.cpt ../bathy/utec_survey/utec/utec_mask.grd -O -K >> $outfile

# add the locations as stars of the utec adcps
psxy $map_area $map_proj -Bg500 -O -K -Sa0.5 -W1/0/0/0 -V positions.xy >> $outfile

# display the image
gs -sPAPERSIZE=a4 $outfile
