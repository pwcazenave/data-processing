#!/bin/bash

# script to generate and plot a surface of the PSMSL values for the english
# channel region. see how it goes...

gmtset LABEL_FONT_SIZE 12
gmtset ANNOT_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 14
gmtset PLOT_DEGREE_FORMAT F

site_nos=(170066 170068 170073 170071 170074 170081 170083 170101 170111 190011 190001 160031 160021 160011 160001 140016 170119 170131 170146 170150 170157 170161 170163 190089 190091 190086 180002 190061 190051 190046 190031 190021 170166 170168 170173 170178 170181 170182)
# don't have data for 160/001 (Antwerpen)...
# added in 170166 170168 170173 170178 170181 170182 - south coast of wales and
# north cornwall

area=-R-10/5/47.5/52.5
proj=-Jm1.5
gres=-I1m
year=1997
tension=0
outfile=./images/psmsl_rlr_surface_$year-T$tension.ps

get_data(){
   rm ./surface/locations.txt ./surface/heights.txt
   touch ./surface/locations.txt ./surface/heights.txt

   for ((i=0; i<${#site_nos[@]}; i++)); do
      if [ -e ./extracted_annual/${site_nos[i]}.rlrdata ]; then
         current_height=$(grep $year ./extracted_annual/${site_nos[i]}.rlrdata)
         if [ -n "$current_height" ]; then
            grep ${site_nos[i]} ./raw_data/final_locations.csv \
               >> ./surface/locations.txt
            echo $current_height | cut -f2 -d" " >> ./surface/heights.txt
            paste -d"," ./surface/heights.txt ./surface/locations.txt | \
               awk -F"," '{print $3,$2,$1,$4,$5}' \
               > ./surface/final_surface.txt
         fi
      fi
   done
}

mksurf(){
   surface $area $gres -T$tension \
      -G./grids/psmsl_surface_-T"$tension".grd ./surface/final_surface.txt
}

plot(){
   makecpt -T6800/7300/0.1 -Z -Cwysiwyg > ./psmsl_rlr.cpt
   grdimage $area $proj ./grids/psmsl_surface_-T"$tension".grd \
      -Ba1f0.5g1:.PSMSL\ RLR\ Surface\ for\ $year\ \(-T=$tension\):WeSn -C./psmsl_rlr.cpt -Xc -Yc -K > $outfile
   # add a coastline for the area
   pscoast $area $proj -Ba5f2.5g5WeSn -Df -G0/0/0 -O -K -N1/255/255/255 \
      -W1/255/255/255 >> $outfile
   psscale -D23.5/6/6/0.5 -Ba100f50 -C./psmsl_rlr.cpt -O -K >> $outfile
   pstext $area $proj -N -O -K << TEXT >> $outfile
   5.55 51.6 12 0 0 1 Height (mm)
TEXT
   # add station locations
   psxy $area $proj ./surface/final_surface.txt -Sa0.4 -W1/100/100/100 \
      -G255/255/255 -O -K >> $outfile
   psxy $area $proj ./surface/final_surface.txt -Sa0.2 -W1/0/0/0 \
      -G255/100/0 -O >> $outfile
}

formats(){
   echo -n "convert the image to pdf... "
   ps2pdf -dPDFSETTINGS=/prepress -sPAPERSIZE=a4 "$outfile" "${outfile%.ps}.pdf"
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r90 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=${outfile%.ps}.jpg" \
      "$outfile" > /dev/null
   echo "done."
}

get_data
mksurf
plot
formats

exit 0
