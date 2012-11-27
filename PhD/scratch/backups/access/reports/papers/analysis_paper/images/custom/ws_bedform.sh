#!/bin/bash

# grid the height results

gmtdefaults -D > .gmtdefaults4

gmtset LABEL_FONT_SIZE=18 ANNOT_FONT_SIZE=18
gmtset D_FORMAT=%g PAPER_MEDIA=a4
gmtset COLOR_NAN=128/128/128

area=-R598201/618927/5613228/5627356
parea=$area
harea=-R0/1/0/20
warea=-R0/30/0/20
darea=-R0/360/0/20
proj=-Jx0.0012
hproj=-JX3.2/2
gres=-I200

infile=./raw_data/ws_200m_subset_results_errors_asymm.csv
inbathy=./raw_data/ws_mask_bathy_50m.xyz
outfile=./images/$(basename ${infile%.*}_bedform.ps)

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $outfile ${outfile%.*}.pdf
   echo -n "and png... "
   gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${outfile%.ps}.png $outfile
   echo "done."
}

awk -F, '{if ($3>2) print $1,$2,$15}' $infile | \
   xyz2grd $parea $gres -G./grids/$(basename ${infile%.*}_likelihood.grd)
xyz2grd $parea $gres $inbathy -G./grids/$(basename ${infile%.*}_bathy_coverage.grd)
makecpt -T0/1/0.01 -Cgray \
   > ./cpts/$(basename ${infile%.*}_likelihood.cpt)

gmtset D_FORMAT=%.0f
psbasemap $parea $proj -Ba4000f1000:"Eastings":/a2000f1000:"Northings":WeSn \
   -X4.2 -Yc -K > $outfile
grdimage $parea $proj -C./cpts/$(basename ${infile%.*}_likelihood.cpt) \
   ./grids/$(basename ${infile%.*}_likelihood.grd) -O -K >> $outfile
gmtset D_FORMAT=%g
grd2xyz ./grids/$(basename ${infile%.*}_likelihood.grd) | \
   awk '{if ($3=="NaN") print $1,$2}' | \
   psxy $parea $proj -Sx0.25 -O -K >> $outfile
awk -F, '{print $1,$2}' $inbathy | \
   psmask $parea $proj $gres -N -G128/128/128 -O -K >> $outfile
psmask -C -O -K >> $outfile
# Add in the IOW and Hampshire coastlines
psxy $area $proj -O -K -W5,black -Gwhite -B0 $(pwd)/raw_data/iow_coastline.txt -: >> $outfile
psxy $area $proj -O -K -W5,black -Gwhite -B0 $(pwd)/raw_data/south_coastline.txt >> $outfile
gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
#psscale -D0.5/14/5/0.3 -B0.2:"Presence": -C./cpts/$(basename ${infile%.*}_likelihood.cpt) -O -K >> $outfile

# Add a pie chart of the bed distribution
numsubsets=$(grd2xyz -S ./grids/$(basename ${infile%.*}_bathy_coverage.grd) | wc -l)
numbedformy=$(awk -F, '{if ($3>2 && $15==1) print $0}' $infile | wc -l)
numflat=$(awk -F, '{if ($3>2 && $15!=1) print $0}' $infile | wc -l)
numnotanalysed=$(echo "scale=2; $numsubsets-($numflat+$numbedformy)" | bc -l)

echo "bedforms: $(echo "($numbedformy/$numsubsets)*100" | bc -l)%, flat: $(echo "($numflat/$numsubsets)*100" | bc -l)%, ignored: $(echo "($numnotanalysed/$numsubsets)*100" | bc -l)%"
echo "bedforms: $(echo "($numbedformy/($numbedformy+$numflat))*100" | bc -l)%, flat: $(echo "($numflat/($numbedformy+$numflat))*100" | bc -l)%"

start_waves=0
end_waves=$(echo "scale=2; ($numbedformy/$numsubsets)*360" | bc -l)
start_flat=$end_waves
end_flat=$(echo "scale=2; $end_waves+(($numflat/$numsubsets)*360)" | bc -l)
start_ignored=$end_flat
end_ignored=360

echo $start_waves $end_waves $start_flat $end_flat $start_ignored $end_ignored

gmtset MEASURE_UNIT=inch
psxy $parea $proj -O -SW -W2,black -C./cpts/$(basename ${infile%.*}_likelihood.cpt) \
    << PIE >> $outfile
605200 5614500 1 1.5 $start_waves $end_waves
605200 5614500 0 1.5 $start_flat $end_flat
605200 5614500 0.5 1.5 $start_ignored $end_ignored
PIE
gmtset MEASURE_UNIT=cm


formats $outfile
