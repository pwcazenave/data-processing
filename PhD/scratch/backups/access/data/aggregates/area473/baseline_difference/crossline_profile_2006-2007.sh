#!/bin/bash

# script to take 3 profiles across the difference grids from north to south

area=-R314695/320327/5595450/5599120
proj=-Jx0.0025

trackdir=./tracklines/profiles
gridin=./grids/area473_07-06.grd
cpt=-C./diff.cpt

outfile=./images/ns_profile_06-07.ps
gmtset D_FORMAT %g

# make the profiles
project -C319500/5599000 -E320200/5596800 -G2.5 -N > $trackdir/ns_01.trk
project -C317300/5598500 -E318000/5596200 -G2.5 -N > $trackdir/ns_02.trk
project -C315100/5598000 -E315800/5595600 -G2.5 -N > $trackdir/ns_03.trk

# sample the grid file along the tracks created
grdtrack $trackdir/ns_01.trk -G$gridin -S > $trackdir/ns_2006_01.pfl
grdtrack $trackdir/ns_02.trk -G$gridin -S > $trackdir/ns_2006_02.pfl
grdtrack $trackdir/ns_03.trk -G$gridin -S > $trackdir/ns_2006_03.pfl

# plot the profile on a map, and on a graph
gmtset D_FORMAT %.0f
psbasemap $area $proj -Ba1000f500g1000:"Eastings":/a1000f500g1000:"Northings"::."Area 473 Difference for 2006 and 2007":WeSn -P -Xc -Y17 -K > $outfile
grdimage $area $proj $cpt $gridin -Bg1000 -O -K >> $outfile
psscale -D15/4.5/-4/0.3 -B1 $cpt -O -K >> $outfile
pstext $proj $area -O -K -N << TEXT >> $outfile
320450 5598250 10 0 0 1 Difference (m)
TEXT

# add the location
psxy $area $proj -W7/0/0/0 -O -K $trackdir/ns_2006_01.pfl >> $outfile
psxy $area $proj -W3/200/0/100 -O -K $trackdir/ns_2006_01.pfl >> $outfile
psxy $area $proj -W7/0/0/0 -O -K $trackdir/ns_2006_02.pfl >> $outfile
psxy $area $proj -W3/0/100/200 -O -K $trackdir/ns_2006_02.pfl >> $outfile
psxy $area $proj -W7/0/0/0 -O -K $trackdir/ns_2006_03.pfl >> $outfile
psxy $area $proj -W3/0/200/100 -O -K $trackdir/ns_2006_03.pfl >> $outfile
start=$(head -n1 $trackdir/ns_2006_01.pfl | awk '{print $1,$2}')
end=$(tail -n1 $trackdir/ns_2006_01.pfl | awk '{print $1,$2}')
pstext $area $proj -O -K -N -D-0.3/-0.4 << START_END >> $outfile
$start 10 1 0 1 C
$end 10 1 0 1 C'
START_END
start=$(head -n1 $trackdir/ns_2006_02.pfl | awk '{print $1,$2}')
end=$(tail -n1 $trackdir/ns_2006_02.pfl | awk '{print $1,$2}')
pstext $area $proj -O -K -N -D-0.3/-0.4 << START_END >> $outfile
$start 10 1 0 1 B
$end 10 1 0 1 B'
START_END
start=$(head -n1 $trackdir/ns_2006_03.pfl | awk '{print $1,$2}')
end=$(tail -n1 $trackdir/ns_2006_03.pfl | awk '{print $1,$2}')
pstext $area $proj -O -K -N -D-0.3/-0.4 << START_END >> $outfile
$start 10 1 0 1 A
$end 10 1 0 1 A'
START_END

# add the profiles
gmtset D_FORMAT %g
pro_area=$(awk '{print $3,$4}' $trackdir/ns_2006_02.pfl | minmax -I300/2.5)
pro_proj=-JX16/10
awk '{print $3,$4}' $trackdir/ns_2006_01.pfl | \
   psxy $pro_area $pro_proj -O -K -Ba500f250g500:"Distance along lines A-A', B-B' and C-C' (m)":/a1f0.5g1:"Difference (m)":WeSn -X-1 -Y-13 -W5/200/0/100 >> $outfile
awk '{print $3,$4}' $trackdir/ns_2006_02.pfl | \
   psxy $pro_area $pro_proj -O -K -B0 -W5/0/100/200 >> $outfile
awk '{print $3,$4}' $trackdir/ns_2006_03.pfl | \
   psxy $pro_area $pro_proj -O -B0 -W5/0/200/100 >> $outfile
# label
#a=$(head -n 1 $j | awk '{print $3}')
#aa=$(tail -n 1 $j | awk '{print $3}')
#pstext $pro_area $pro_proj -O -K -N -D0/-0.5 << AAA >> $outfile
#$a -0.65 10 1 0 1 A
#$aa -0.65 10 1 0 1 A'
#AAA
#done

# convert the output
echo -n "convert the image to pdf... "
ps2pdf -dPDFSETTINGS=/prepress -sPAPERSIZE=a4 "$outfile" "${outfile%.ps}.pdf" \
   &> /dev/null
echo -n "and jpeg... "
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
   "-sOutputFile=${outfile%.ps}.jpg" \
   "$outfile" &> /dev/null
echo "done."

