#!/bin/bash

# script to plot the maximum slope of the hastings bathy

#area=-R578117/588357/91508/98708
area=-R578106/588291/91505/98686
proj=-Jx0.0022

# it seems the utec_mask2.grd file was generated with awk to make positive 
# depths instead of negative ones.
infile=./utec_mask2.grd # has |depth| values - makes the direction work
outdir=./images/hastings_dir.ps
outslope=./images/hastings_slope.ps

gmtset D_FORMAT=%.3f MEASURE_UNIT=cm LABEL_FONT_SIZE=18 ANNOT_FONT_SIZE=18

mkgrad()
{
   grdgradient $infile -G${infile%.grd}_dir.grd -D -S${infile%.grd}_slope.grd
}

mkdegrees()
{
   # convert radians to degrees
   grdmath ${infile%.grd}_slope.grd ATAN 57.29577951 MUL = \
      ${infile%.grd}_deg.grd
}

palette()
{
#   grd2cpt $area -Ccyclic ${infile%.grd}_dir.grd -Z > ./dir.cpt
   makecpt -Ccyclic -T0/360/20 -Z > ./dir.cpt
#   grd2cpt $area -Cwysiwyg ${infile%.grd}_deg.grd -Q -Z > ./slope.cpt
   makecpt -Crainbow -T-0.25/1.5/0.001 -Z -Q > ./slope.cpt
   # have to make a custom slope colour palette:
#   cat << SLOPE > ./slope.cpt
##COLOR_MODEL = RGB
##
#0.0     64      0       64      0.8     64      0       192
#0.8     0       64      255     1.6    0       128     255
#1.6     0       160     255     2.4     64      192     255
#2.4     64      224     255     3.2     64      255     255
#3.2     64      255     192     4       64      255     64
#4       128     255     64      4.8     192     255     64
#4.8     255     255     64      5.6     255     224     64
#5.6     255     160     64      10      255     96      64
#10      255     32      64      20      255     96      192
#20      255     160     255     80.000  255     224     225
#B       128     128     128
#F       255     255     255
#N       128     128     128
#SLOPE
}

plot_dir()
{
   gmtset D_FORMAT %g
   grdimage $area $proj ${infile%.grd}_dir.grd -C./dir.cpt -K -Xc -Yc \
      > $outdir
   psbasemap $area $proj -O -K \
      -Ba2000f500g1000:"Eastings":/a1000f500g1000:"Northings":WeSn \
      >> $outdir
   psscale -D23.3/7/7/0.5 -Ba90f10 \
      -C./dir.cpt -O -K >> $outdir
   pstext $area $proj -O -K -N << DIR >> $outdir
   588420 96700 18 0 0 1 Aspect (@+o@+)
DIR

   gmtset D_FORMAT %.2f
}

plot_slope()
{
   gmtset D_FORMAT %g
   gmtset COLOR_BACKGROUND 128/128/128
   grdimage $area $proj ${infile%.grd}_deg.grd -C./slope.cpt -K -Xc -Yc \
      > $outslope
   psbasemap $area $proj -O -K \
      -Ba2000f500g1000:"Eastings":/a1000f500g1000:"Northings":WeSn \
      >> $outslope
   psscale -D23.3/7/7/0.5 -Ba5f1 -C./slope.cpt -O -K \
      >> $outslope
   pstext $area $proj -O -K -N << SLOPE >> $outslope
   588500 96700 18 0 0 1 Slope (@+o@+)
SLOPE

   gmtset D_FORMAT %.2f
#   gmtset COLOR_BACKGROUND 0/0/0
}

formats()
{
#   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
#      -sOutputFile=${outdir%.ps}.jpg $outdir
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${outslope%.ps}.jpg $outslope
#   ps2pdf -q -sPAPERSIZE=a4 $outdir ${outdir%.ps}.pdf
   ps2pdf -q -sPAPERSIZE=a4 $outslope ${outslope%.ps}.pdf
}

#mkgrad
#mkdegrees
palette
plot_dir
#plot_slope
formats

exit 0
