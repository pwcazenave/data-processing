#! /bin/csh

# script to plot the position of the ADCPs from site 2 and 3 of the utec data on the bathy map

set map_area=-R578117/588284/91508/98686
set map_proj=-Jx0.002
set text_area=-R0/30/0/20
set text_plot=-JX30/20
set outfile=map.ps

set tracklines=~/scratch/project/bathy/utec_survey/tracklines/tracklines.txt
set bathy_grid=~/scratch/project/bathy/utec_survey/utec/utec_mask.grd
set bathy_grad=~/scratch/project/bathy/utec_survey/utec/utec_grad.grd
set bathy_mask=~/scratch/project/bathy/utec_survey/utec/mask.grd # for image without bathy
set bathy_cpt=~/scratch/project/bathy/utec_survey/utec/utec.cpt
set adcp_positions=~/scratch/project/adcp/positions.xy
set grain_size=~/scratch/project/grain_size/data.txt

gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 16

# add a basemap
psbasemap $map_area $map_proj -Ba2000f1000g500:"Eastings":/a2000f1000g500:"Northings":WeSn -Xc -Yc -K > $outfile

# add the mask
grdimage $map_area $map_proj -C$bathy_cpt $bathy_mask -O -K >> $outfile

# add the contours
#grdcontour $bathy_grid $map_proj $map_area -A25 -O -K -S50 >> $outfile

# add the tracklines
awk '{print $1, $2, ($5/495)}' $tracklines | awk '{printf "%7.2f %7.2f 63 %8s\n", $1, $2, $3}' | psxy $map_proj $map_area -H9 -W1/200/0/50 -SV0/0/0 -O -K >> $outfile

# add the locations as stars of the utec adcps
psxy $map_area $map_proj -Bg500 -O -K -Sa0.5 -G0/200/50 -W1/0/0/0 $adcp_positions >> $outfile

# add the grab locations
psxy $map_proj $map_area $grain_size -O -Sc0.3 -G0/50/200 -W0/0/0 >> $outfile

# display the image
gs -sPAPERSIZE=a4 $outfile
