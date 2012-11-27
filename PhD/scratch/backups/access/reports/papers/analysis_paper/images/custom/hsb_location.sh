#!/bin/bash

# Quickly plot the Hastings illuminated bathy with the grain size and
# ADCP locations on it too for the paper.

gmtdefaults -D > .gmtdefaults4
gmtset LABEL_FONT_SIZE=14 BASEMAP_TYPE=plain

formats(){
   echo -n "converting to pdf, "
   ps2pdf -sPAPERSIZE=a4 -dAutoRotatePages=/PageByPage -dPDFSETTINGS=/prepress -q $1 ${1%.*}.pdf
   echo -n "png, "
   gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.png $1
   echo -n "jpeg, "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.jpg $1
   echo -n "and png... "
   gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.png $1
   echo "done."
}

hsb=../../../../mres/project/bathy/utec_survey/hsb_plot/grids/all_lines_blockmedian_1m.grd
gs=../../../../mres/project/grain_size/grain_size.txt
adcp=../../../../mres/project/adcp/positions.xy

area=$(grdinfo -I1 $hsb)
proj=-Jx0.00215
uk_area=-R-7/3/49/54
uk_proj=-Jm0.5
cpt=./cpts/$(basename ${hsb%.*}).cpt


outfile=./images/hsb_location.ps

makecpt $(grdinfo -T1 $hsb) -Z > $cpt

psbasemap $area $proj -Xc -Yc -K \
    -Ba2000f500:"Eastings":/a1000f500:"Northings":WeSn > $outfile

# Bathy
grdimage $area $proj -C$cpt -I${hsb%.*}_grad.grd $hsb -O -K >> $outfile

# Grain locations
awk '{print $1,$2}' $gs | psxy $area $proj -Sc0.4 -Gwhite -W3,black -O -K >> $outfile

# ADCP locations
awk '{print $1,$2}' $adcp | psxy $area $proj -Sa0.7 -Gwhite -W3,black -O -K >> $outfile
awk '{print $1,$2,"16 0 0 1",$NF}' $adcp | pstext $area $proj -WwhiteO0,white -D0.5/-0.2 -O -K >> $outfile

# Licence area
psxy $area $proj -O -K -W5,white -L ./raw_data/hsb_licence.xy >> $outfile

# Add subset locations
psxy $area $proj -W5 -O -K << BOX >> $outfile
579000 97000
582000 97000
582000 95000
579000 95000
579000 97000
BOX
psxy $area $proj -W5 -O -K << BOX >> $outfile
585000 97000
586500 97000
586500 95500
585000 95500
585000 97000
BOX

# Add in some labels
pstext $area $proj -O -K -D0.15/0.15 -WwhiteO0,white << TEXT >> $outfile
579000 95000 16 0 0 1 A
585000 95500 16 0 0 1 B
TEXT

gmtset ANNOT_FONT_SIZE=10 LABEL_FONT_SIZE=12
psscale -D14/2.4/-5/0.5h -B10:"Depth (m)": -C$cpt -I -O -K >> $outfile

# Location map
pscoast $uk_area $uk_proj -X17 -Y0.3 -B0wesn -O -K -Dh -Swhite -Ggray -W0/0/0 >> $outfile
psxy $uk_area $uk_proj -O -K -W3 << LOCATION >> $outfile
0.525036 50.691208
0.525508 50.762306
0.673185 50.762603
0.673184 50.691208
0.525036 50.691208
LOCATION
pstext $uk_area $uk_proj -D0.1/-0.3 -O -K << HSB >> $outfile
0.673184 50.691208 10 0 0 1 HSB
HSB
psxy $uk_area $uk_proj -O -K -Sc0.15 -W2,black -Gwhite << LONDON >> $outfile
0.221522 51.469393
LONDON
pstext $uk_area $uk_proj -D-1.3/0.2 -O -WwhiteO0,white << LONDON >> $outfile
0.221522 51.469393 10 0 0 1 London
LONDON

formats $outfile
