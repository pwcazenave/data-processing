#!/bin/bash

# quick script to plot the new 2007 bathy from area473

infile=./raw_data/area473_2007_lines_corrected-odn.txt
#infile=./raw_data/qloud_output.pts
outfile=./images/area473_2007.ps

area=-R314695/320327/5595450/5599120
proj=-Jx0.0033

gmtset D_FORMAT %.2f

bm() {
   echo -n "blockmedian... "
   blockmedian $area -I1 $infile > ${infile%.txt}.bmd
}

mksurf() {
   echo -n "surface... "
   surface -Garea473_2007_interp.grd -I1 $area -T0.25 ${infile%.txt}.bmd
}

mkgrad() {
   echo -n "gradient... "
   grdgradient area473_2007_interp.grd -A255 -Nt0.5 -Garea473_2007_grad.grd
}

mkmask() {
   echo -n "mask... "
   grdmask ${infile%.txt}.bmd -Garea473_2007_mask.grd -I1 $area -N/NaN/1/1 -S5
}

grdadd() {
   echo -n "maths... "
   grdmath area473_2007_interp.grd area473_2007_mask.grd MUL = area473_2007.grd
echo "done."
}

plot() {
echo -n  "plot... "
   makecpt -Crainbow -T40.8/49/0.1 -I -Z > area473.cpt
   #grd2cpt area473_2007.grd -Crainbow $area -Z -I -L41/50 > area473.cpt
   gmtset D_FORMAT %.0f
   grdimage $area $proj \
      -Iarea473_2007_grad.grd -Carea473.cpt area473_2007.grd -K -Xc -Yc \
      > $outfile
#      -Ba1000f500g1000:"Eastings":/a1000f500g1000:"Northings":WeSn \
   # add the magic mask outline
#   psxy $area $proj -O -K -Sp ../baseline_difference/grids/outline.xy \
#      >> $outfile
   psscale -D19.5/6/-5/0.5 -B1 -Carea473.cpt -O -K >> $outfile
   pstext $proj $area -O -N << TEXT >> $outfile
   320600 5598250 10 0 0 1 Depth (m)
TEXT
}

conv() {
   echo -n "convert the image to pdf... "
   ps2pdf -dPDFSETTINGS=/prepress -sPAPERSIZE=a4 "$outfile" "${outfile%.ps}.pdf"
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=${outfile%.ps}.jpg" \
      "$outfile" > /dev/null
   echo "done."
}

echo -n "the usual routine: "
#bm              # blockmean
#mksurf          # make the surfaces
#mkgrad          # make the gradient files
#mkmask          # generate the masks
#grdadd          # add the grids
plot            # plot the grids
conv            # convert the output
echo "done."

exit 0
