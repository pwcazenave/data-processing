#!/bin/bash

# script to get all the sites' data for the southern north sea and english \
# channel


gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14 HEADER_FONT_SIZE=16

area=-R1950/2003/6700/7400
proj=-JX22/14
annot=-Ba5f1g5:"Year":/a100f50g100:,-mm::Height\ above\ RLR\ \(Revised\ Local\ Reference\)::.PSMSL\ Sea\ Level\ Curves\ for\ the\ model\ domain:WeSn
outfile=./images/all_curves.ps

site_nos=(170066 170068 170073 170071 170074 170081 170083 170101 170111 190011 190001 160031 160021 160011 160001 140016 170119 170131 170146 170150 170157 170161 170163 190089 190091 190086 180002 190061 190051 190046 190031 190021 170166 170168 170173 170178 170181 170182)
# don't have data for 160/001 (Antwerpen)...
# added in 170166 170168 170173 170178 170181 170182 - south coast of wales and
# north cornwall

colours=(34/139/34 200/0/50 160/32/240 255/127/36 0/0/0 188/238/104 100/100/100 0/0/128 0/191/255 255/218/185 230/230/250 47/79/79 112/128/144 128/0/128 0/191/255 175/238/238 0/100/0 32/178/170 124/252/0 255/215/0 188/143/143 139/69/19 178/34/34 240/128/128 255/20/147 221/160/221 148/0/211 224/238/224 0/255/0 255/246/143 139/139/0 139/105/105 255/48/48 255/169/0 50/200/1 75/99/129 190/31/45 20/50/100 50/50/255 75/248/100)

# get the data file, and the documentation to match
get_data(){
   for ((i=0; i<${#site_nos[@]}; i++)); do
      for_copy_current=./raw_data/rlr.annual.data/${site_nos[i]}.rlrdata
      if [ -e $for_copy_current ]; then
         cp $for_copy_current ./extracted_annual/
         cp ./raw_data/docu.psmsl/"${site_nos[i]}".docu \
            ./extracted_annual/docs/
      fi
   done
}

plot_data(){
   psbasemap $area $proj -B0 -Xc -Yc -K > $outfile
   for ((i=0; i<${#site_nos[@]}; i++)); do
      plot_current=./extracted_annual/${site_nos[i]}.rlrdata
      if [ -e $plot_current ]; then
         awk '{print $1,$2}' $plot_current | \
            psxy $area $proj -W5/"${colours[i]}" -O -K >> $outfile
         awk '{print $1,$2}' $plot_current | \
            psxy $area $proj -W3/"${colours[i]}" -Sc0.1 -O -K >> $outfile
      fi
   done
}

labels(){
   psbasemap $area $proj "$annot" -O -K >> $outfile
   xline=1950.75
   yline=7380
   xstep=1.4
   for ((i=0; i<${#site_nos[@]}; i++)); do
      label_current=./extracted_annual/${site_nos[i]}.rlrdata
      if [ -e $label_current ]; then
         docu=./extracted_annual/docs/${site_nos[i]}.docu
         station=$(grep Station\ name $docu | cut -f4- -d" ")
         x2=$(echo "scale=2; $xline+1" | bc -l)
         psxy $area $proj -O -K -W8/"${colours[i]}" << LINE \
            >> $outfile
         $xline $yline
         $x2 $yline
LINE
         xtext=$(echo "scale=2; $xline+0.25" | bc -l)
         ytext=$(echo "scale=2; $yline-10" | bc -l)
         pstext $area $proj -O -K -W255/255/255 << TEXT >> $outfile
         $xtext $ytext 8 270 0 1 $station
TEXT
         xline=$(echo "scale=2; $xline+$xstep" | bc -l)
      fi
   done
   psbasemap $area $proj -B0 -O >> $outfile
}

formats(){
   # convert the images
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress "$outfile" \
      ${outfile%.ps}.pdf
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=${outfile%.ps}.jpg" \
      "$outfile" > /dev/null
   echo "done."
}

#get_data
plot_data
labels
formats

exit 0
