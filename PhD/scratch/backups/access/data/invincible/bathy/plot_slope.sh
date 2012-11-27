#!/bin/bash
#
# script to
#

gmtset LABEL_FONT_SIZE 12
gmtset ANNOT_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 14
gmtset PLOT_DATE_FORMAT dd/mm/yyyy
gmtset D_FORMAT %g

infile=./raw_data/invincible_slope2.txt
outfile=./images/invincible_slope.ps
name=invincible_slope

area=-R638250/638560/5622600/5622780
proj=-Jx0.07

bm(){
   echo -n "blockmeaning... "
   gmtset D_FORMAT %.2f
   blockmedian $area -I0.2 $infile > ${infile%.txt}.bmd
   gmtset D_FORMAT %g
}

mksurf() {
   echo -n "surface... "
   surface -G./grids/"$name"_interp.grd -I0.2 $area -T0.25 ${infile%.txt}.bmd
}

mkgrad() {
   echo -n "gradient... "
   grdgradient ./grids/"$name"_interp.grd -A140 -Nt0.7 \
      -G./grids/"$name"_grad.grd
}

mkmask() {
   echo -n "mask... "
   grdmask ./raw_data/invincible_solent.bmd -G./grids/"$name"_mask.grd \
      -I0.2 $area -N/NaN/1/1 -S1
}

grdadd() {
   echo -n "maths... "
   grdmath ./grids/"$name"_interp.grd ./grids/"$name"_mask.grd MUL \
      = ./grids/"$name".grd
echo "done."
}

plot() {
echo -n  "plot... "
#   makecpt -Crainbow -T0/20/0.1 -I -Z > "$name".cpt
   grd2cpt ./grids/"$name".grd $area -Crainbow > "$name.cpt"
   gmtset D_FORMAT %.0f
   grdimage $area $proj \
      -Ba50f25g50:"Eastings":/a50f25g50:"Northings":WeSn \
      -I./grids/"$name"_grad.grd -C"$name".cpt ./grids/"$name".grd -K -Xc -Yc \
      > $outfile
   gmtset D_FORMAT %g
   psscale -D22.5/6/-5/0.5 -B10 -C"$name".cpt -O -K >> $outfile
   pstext $proj $area -O -N << TEXT >> $outfile
   638568.5 5622730 12 0 0 1 Slope (@+o@+)
TEXT
}

formats() {
   echo -n "convert the image to pdf... "
   ps2pdf -dPDFSETTINGS=/prepress -sPAPERSIZE=a4 "$outfile" "${outfile%.ps}.pdf"
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=${outfile%.ps}.jpg" \
      "$outfile" > /dev/null
}

echo -n "the usual routine: "
bm              # blockmean
mksurf          # make the surfaces
mkgrad          # make the gradient files
mkmask          # generate the masks
grdadd          # add the grids
plot            # plot the grids
formats         # convert the output
echo "done."

exit 0
