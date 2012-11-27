#! /bin/csh

# script to plot the track lines of the utec bathymetry survey, with the survey extent and the dredging area too.

set area=-R578117/588284/91508/98686
set proj=-JX15/11
set outfile=surveylines.ps

gmtset BASEMAP_TYPE = fancy
gmtset LABEL_FONT_SIZE = 12
gmtset HEADER_FONT_SIZE	= 16p

psbasemap $proj $area -Ba1500f750g750:"Eastings":/a1500f750g750:"Northings"::."UTEC Survey Lines":WeSn -Xc -Yc -P -K > $outfile
grdimage $area $proj ../utec/utec_mask.grd -C../utec/utec.cpt -O -K >> $outfile
awk '{print $1, $2, ($5/660)}' tracklines.txt | awk '{printf "%7.2f %7.2f 28 %8s\n", $1, $2, $3}' | psxy $proj $area -H9 -W1/0/0/255 -Sv0/0/0 -O >> $outfile

# view the image
gs -sPAPERSIZE=a4 $outfile
#ps2pdf $outfile

 awk '{printf "%4s-%2s-%2sT%8s %2.2f\n", $3, $2, $1, $4, $5}' >
