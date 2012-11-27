#!/bin/bash
#
# script to plot the trend residual and the profile location
#

gmtset LABEL_FONT_SIZE 12
gmtset ANNOT_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 14
gmtset PLOT_DATE_FORMAT dd/mm/yyyy
gmtset D_FORMAT %g

indir=./raw_data/trendlines
outdir=./images/trendlines

proj=-JX16/11

plot_trends(){
   echo -n "plot the trendlines... "
   for trend in $indir/*.xy; do
      # add the trend residual
      area=$(awk '{print $1,$3}' $trend | minmax -I20/0.5)
      awk '{print $1,$3}' $trend | \
         psxy $area $proj -W3/0/0/0 -K -Xc -Y17 -P \
	 -Ba150f75:"Distance along transect (m)":/a0.5f0.25:"Residual Depth (m)":WeSn \
	 > $outdir/$(basename $trend .xy).ps

      # add the location
      map_area=-R578117/588284/91508/98686
      map_proj=-Jx0.00156
      psbasemap $map_area $map_proj -P \
         -Ba2000f1000:"Eastings":/a2000f1000:"Northings"::."Profile Location":WeSn \
         -Y-15 -O -K >> $outdir/$(basename $trend .xy).ps
      makecpt -Crainbow -T-47/-13/0.1 -Z > ./grids/hastings.cpt
      grdimage $map_area $map_proj -O -K ./grids/hastings_bathy.grd \
	 -C./grids/hastings.cpt \
	 >> $outdir/$(basename $trend .xy).ps
      
#      outline=../../project/bathy/utec_survey/raw_data/outline.xy
#      psxy $map_area $map_proj -O -K $outline -Sc0.1 \
#	 -Ba1000f500:"Eastings":/a2000f1000:"Northings":WeSn \
#	 >> $outdir/$(basename $trend .xy).ps
      psxy $map_area $map_proj -O -W5/0/0/0 \
	 ./raw_data/tracklines/$(basename ${trend%_trend*}.xy) \
	 >> $outdir/$(basename $trend .xy).ps
   done
   echo "done."
}

formats(){
   echo -n "convert outputs to pdf and jpeg... "
   for image in $outdir/*.ps; do
      ps2pdf -dPDFSETTINGS=/prepress -sPAPERSIZE=a4 \
         "$image" "${image%.ps}.pdf"
      gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
         "-sOutputFile=${image%.ps}.jpg" \
         "$image" > /dev/null
   done
   echo "done."
}

plot_trends             # plot the trendlines on a figure
formats			# convert the images

exit 0
