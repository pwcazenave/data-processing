#! /bin/bash

# script to ouput the profiles of the bathymetry made using surfer

map_area=-R578117/588284/91508/98686
map_proj=-Jx0.002
text_area=-R0/30/0/20
text_proj=-JX30/20
map_outfile=plots/locations.ps

# the location map
makecpt -Crainbow -T-47/-13/0.1 -Z > ./grids/utec.cpt
psbasemap $map_area $map_proj \
   -Ba2000f1000:"Eastings":/a2000f1000:"Northings"::."Profile Location":WeSn \
   -Xc -Yc -K > $map_outfile
grdimage $map_area $map_proj \
   -C./grids/utec.cpt \
   -I./grids/hastings_grad.grd \
   ./grids/hastings_bathy.grd \
   -O -K -Bg1000 \
   >> $map_outfile

psscale -D21.1/6.5/5/0.5 -B5 \
   -C../../bathy/utec_survey/utec/utec.cpt -O -K \
   >> $map_outfile
pstext $text_area $text_proj -O -K << TEXT >> $map_outfile
21 9.5 12 0 0 1 Depth (m)
TEXT

#1!> start the loop
iterations=$(ls raw_data/*.dat | awk -F"/" '{print $2}')
for i in $iterations; do
   input=raw_data/$i

   # what am i working on?
   echo "Working on $input"

   mktrans(){
      grdtrack $input -S -G../../bathy/utec_survey/utec/utec_mask.grd \
         > ${input%.dat}.xy
   }
   
   mkparams(){
      plot_outfile=plots/residual/profile_${i%.dat}.ps
      plot_area=$(awk '{print $3,$4}' ${input%.dat}.xy | minmax -I10/0.5)
      plot_proj=-JX15/8
   }
 
   location(){
      # plot the transect location on the location map plots/locations.ps
      awk '{print $1, $2}' $input | \
         psxy $map_area $map_proj -Bg500 -O -K -W4/255/255/255 >> $map_outfile
      awk '{print $1, $2}' $input | \
         psxy $map_area $map_proj -Bg500 -O -K -W3/0/0/0 >> $map_outfile
      psbasemap $plot_area $plot_proj \
         -Ba200f100g100:"Distance along line (m)":/a1f0.5g0.5WeSn:"Depth (m) CD"::."$i profile": \
         -Xc -Y17 -K -P > $plot_outfile
   }

   plot_profile(){
      awk '{print $3, $4}' ${input%.dat}.xy | \
         psxy $plot_area $plot_proj -O -K -W3/0/0/0 >> $plot_outfile
   }

   mktrends(){
      # calculate and plot a number of "strength" trend lines
      # create a set of three different trends and plot them on top of the 
      # existing data
      awk '{print $3, $4}' ${input%.dat}.xy | trend1d -N10 -Fxmr \
         > ${input%.dat}_trend_10_red.xy
      psxy $plot_area $plot_proj -W3/200/0/50 -O -K \
         ${input%.dat}_trend_10_red.xy \
         >> $plot_outfile
      awk '{print $3, $4}' ${input%.dat}.xy | trend1d -N20 -Fxmr \
         > ${input%.dat}_trend_20_green.xy
      psxy $plot_area $plot_proj -W3/0/200/50 -O -K \
         ${input%.dat}_trend_20_green.xy \
         >> $plot_outfile
      awk '{print $3, $4}' ${input%.dat}.xy | trend1d -N30 -Fxmr \
         > ${input%.dat}_trend_30_blue.xy
      psxy $plot_area $plot_proj -W3/50/0/200 -O -K \
         ${input%.dat}_trend_30_blue.xy \
         >> $plot_outfile
   }
   
   plot_res(){
      # create a new plot area for the residual values
      plot_area_subset=-R$(minmax ${input%.dat}_trend_30_blue.xy | \
         tr "/<>" " " | \
         awk 'BEGIN {OFS="/"} {print $6,($7+50),($10-1.5),($11+1.5)}')
      psbasemap $plot_area_subset $plot_proj \
         -Ba200f100g100:"Distance along line (m)":/a1f0.5g0.5WeSn:"Residual Depth (m)"::."$i profile": \
         -Y-13 -O -K -P >> $plot_outfile
      awk '{print $1, $3}' ${input%.dat}_trend_10_red.xy | \
         psxy $plot_area_subset $plot_proj -W3/200/0/50 -O -K >> $plot_outfile
      awk '{print $1, $3}' ${input%.dat}_trend_20_green.xy | \
         psxy $plot_area_subset $plot_proj -W3/0/200/50 -O -K >> $plot_outfile
      awk '{print $1, $3}' ${input%.dat}_trend_30_blue.xy | \
         psxy $plot_area_subset $plot_proj -W3/50/0/200 -O -K >> $plot_outfile
   }

   formats(){
      # convert the output to jpeg and pdf
      echo -n "convert $plot_outfile to pdf... "
      ps2pdf -dPDFSETTINGS=/prepress -sPAPERSIZE=a4 "$plot_outfile" \
         "${plot_outfile%.ps}.pdf"
      echo -n "and jpeg... "
      gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
         "-sOutputFile=${plot_outfile%.ps}.jpg" \
         "$plot_outfile" > /dev/null
      echo "done."
   }
  
   status_report(){
      # what have i just finished working on?
      echo "Done $input"
      echo "Created file ./$plot_outfile"
      echo ""
   }
   
   mktrans              # make the depth profiles
   mkparams             # set area, proj etc.
   location             # add the locations
   plot_profile         # plot the profile
   mktrends             # apply the trendlines
   plot_res             # plot the trend residual
   formats              # convert the images
   status_report        # duh...

done

echo -n "convert $map_outfile to pdf... "
ps2pdf -dPDFSETTINGS=/prepress -sPAPERSIZE=a4 "$map_outfile" \
   "${map_outfile%.ps}.pdf"
echo -n "and jpeg... "
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
   "-sOutputFile=${map_outfile%.ps}.jpg" \
   "$map_outfile" > /dev/null
echo "done."

exit 0
