#!/bin/bash

# Script to plot the original data, the filtered data and the difference
# to illustrate the filtering process and its effect

gmtset LABEL_FONT_SIZE=16 ANNOT_FONT_SIZE=16


set -eu

indata=../mca_orig_inv_diff_bathy.csv
inpoints=../mca_picked_crest-troughs.csv

area=$(grdinfo -I1 ./grids/mca_bathy.grd)
proj=-Jx0.018
parea=-R609710/609790/5621650/5621760
pproj=-Jx0.15
gres=-I1

gridpref=./grids/$(basename ${indata%.*})

outfile=./images/$(basename ${indata%.*}.ps)
outpoints=./images/$(basename ${inpoints%.*}.ps)

formats(){
    if [ $# -eq 0 ]; then
        echo "Converts PostScript to pdf and png.";
        echo "Error: not enough inputs.";
        echo "Usage: formats file1.ps [file2.ps] ... [filen.ps]";
    fi;
    for i in "$@";
    do
        echo -n "converting $i to pdf ";
        ps2pdf -sPAPERSIZE=a4 -dAutoRotatePages=/PageByPage -dPDFSETTINGS=/prepress -q "$i" "${i%.*}.pdf";
        echo -n "and png... ";
        gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q -sOutputFile="${i%.ps}.png" "$i";
        echo "done.";
    done
}


mk_bathy(){
   awk -F"," '{print $1,$2,$3}' $indata | \
      xyz2grd $area $gres -G${gridpref}_1.grd
   awk -F"," '{print $1,$2,$4}' $indata | \
      xyz2grd $area $gres -G${gridpref}_2.grd
   awk -F"," '{print $1,$2,$5}' $indata | \
      xyz2grd $area $gres -G${gridpref}_3.grd
}

mk_grad(){
   for i in ${gridpref}_?.grd; do
      grdgradient -Nt0.1 -A250 ${i} -G${i%.grd}_grad.grd
   done
}

plot_bathy(){
   #makecpt $(grdinfo -T0.1 ${gridpref}_2.grd) -Crainbow -Z > ./cpts/mca_bathy_clipped.cpt
   makecpt -T-0.5/0.5/0.01 -Crainbow -Z > ./cpts/mca_bathy_clipped.cpt
   gmtset D_FORMAT=%.0f
   psbasemap $area $proj -Ba200f50:"Eastings":/a100f50:"Northings":WeSn \
      -X3.6 -Yc -K > $outfile
   gmtset D_FORMAT=%lg
   grdimage $area $proj -C./cpts/mca_bathy.cpt ${gridpref}_1.grd \
      -I${gridpref}_1_grad.grd -O -K >> $outfile
   psscale -D3/-2.3/4.5/0.25h -C./cpts/mca_bathy.cpt -I -Ba1f0.5:"Depth (m)": -O -K >> $outfile
   gmtset D_FORMAT=%.0f
   psbasemap $area $proj -Ba200f50:"Eastings":/a100f50WeSn \
      -X9.9 -O -K >> $outfile
   gmtset D_FORMAT=%lg
   grdimage $area $proj -C./cpts/mca_bathy_clipped.cpt ${gridpref}_2.grd \
      -I${gridpref}_2_grad.grd -O -K >> $outfile
   psscale -D3/-2.3/4.5/0.25h -C./cpts/mca_bathy_clipped.cpt -I -Ba0.4f0.1:"Depth (m)": -O -K >> $outfile
   gmtset D_FORMAT=%.0f
   psbasemap $area $proj -Ba200f50:"Eastings":/a100f50WeSn \
      -X9.9 -O -K >> $outfile
   gmtset D_FORMAT=%lg
   grdimage $area $proj -C./cpts/mca_bathy.cpt ${gridpref}_3.grd \
      -I${gridpref}_3_grad.grd -O -K >> $outfile
   psscale -D3/-2.3/4.5/0.25h -C./cpts/mca_bathy.cpt -I -Ba1f0.5:"Depth (m)": -O >> $outfile

   formats $outfile
}

plot_points(){
   gmtset D_FORMAT=%lg
   makecpt -T14/16.5/0.1 -I -Crainbow -Z > ./cpts/mca_bathy_subset.cpt
   gmtset D_FORMAT=%.0f
   psbasemap $parea $pproj -Ba25f5:"Eastings":/a25f5:"Northings":WeSn -P \
      -Xc -Yc -K > $outpoints
   gmtset D_FORMAT=%lg
   grdimage $parea $pproj -C./cpts/mca_bathy_subset.cpt ${gridpref}_1.grd \
      -I${gridpref}_1_grad.grd -O -K >> $outpoints
   psxy $parea $pproj $inpoints -Sc0.15 -W4,white -O >> $outpoints
#   psscale -D3/-2.3/4.5/0.25h -C./cpts/mca_bathy.cpt -I -Ba1f0.5:"Depth (m)": -O -K >> $outfile
   formats $outpoints
}


#mk_bathy
#mk_grad
plot_bathy
plot_points
