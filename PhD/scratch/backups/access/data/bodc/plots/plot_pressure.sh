#!/bin/bash

# script to plot the pressure sensor tidal curves, converting to depth along
# the way

gmtset INPUT_DATE_FORMAT yyyy/mm/dd
gmtset PLOT_DATE_FORMAT dd/mm/yyyy
gmtset INPUT_CLOCK_FORMAT hh.mm.ss
gmtset PLOT_CLOCK_FORMAT hh:mm:ss
gmtset MEASURE_UNIT cm
gmtset ANNOT_FONT_SIZE 10p
gmtset LABEL_FONT_SIZE 12p
gmtset HEADER_FONT_SIZE 14p

wa_infile=./raw_data/b0034254_*.dat
tor_infile=./raw_data/b0033933_*.dat
outfile=./images/pressure_sensor.ps

wa_area=-R1980-09-07T09:00/1980-10-21T19:00/134/143
tor_area=-R1977-06-28T11:00/1977-08-12T18:00/52/60
proj=-JX15cT/10c

# do the western approaches first
western()
{
   awk 'NR>13 {print $2"T"$3,$4/100}' $wa_infile | \
      psxy $wa_area $proj -K -Xc -Y17 -W5/200/50/0 -P \
         -Ba12Df1Dg12D/a1f0.5g1:"Depth (decibar=red, metres=blue)":WeSn \
         -B:."Pressure sensor data from the Western Approaches, September-October 1980": \
         > $outfile
   awk 'NR>13 {print $2"T"$3,($4/100)*1.019716}' $wa_infile | \
      psxy $wa_area $proj -O -K -W5/0/50/200 \
         -B0 \
         >> $outfile
}

tor_bay()
{
   awk 'NR>13 {print $2"T"$3,$4/100}' $tor_infile | \
      psxy $tor_area $proj -O -K -Y-13.5 -W5/200/50/0 -P \
         -Ba12Df1Dg12D/a1f0.5g1:"Depth (decibar=red, metres=blue)":WeSn \
         -B:."Pressure sensor data from Tor Bay, July-August, 1977": \
         >> $outfile
   awk 'NR>13 {print $2"T"$3,($4/100)*1.019716}' $tor_infile | \
      psxy $tor_area $proj -O -W5/0/50/200 \
         -B0 \
         >> $outfile
}

formats()
{
   echo -n "converting $outfile to pdf "
   ps2pdf -sPAPERSIZE=a4 "$outfile" "${outfile%.ps}.pdf" > /dev/null
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r600 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=${outfile%.ps}.jpg" \
      "$outfile" > /dev/null
   echo "done."
}

western
tor_bay
formats

exit 0
