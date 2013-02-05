#! /bin/csh

echo "In order for this script to work, you MUST setup GMT version v3.4.5. GMT 4.0 will not work."

# plotting images of seismic profiles using seismic unix (su) for use in presentation/writeup:

# read in the seg-y file and output to su format
segyread tape=line107.sgy verbose=1 vblock=500 endian=0 | segyclean | supsimage height=9.0 width=4.5 style=normal f1num=-1 d1num=100.0 n1tic=0 f2num=100000 d2num=100000.0 n2tic=0 brgb=0,0,0 grgb=1.0,1.0,1.0 wrgb=1.0,1.0,1.0 x1beg=4 x1end=7.5 perc=99.7 > section_107.ps

# amend the GMT defaults file (.gmtdefaults)
gmtset PAPER_MEDIA a4+
gmtset HEADER_FONT_SIZE 20p
gmtset LABEL_FONT_SIZE 14p

# create GMT adornments - must be done with GMT version v3.4.5.
psbasemap -R135.810/148.065/4000/7500 -JX9/-4.5 -Ba1.000f.500:"CDP (x10@+3@+)":/a1000f500:"TWT (ms)":NW -K > overlay_107.ps
psbasemap -R0/76.34/4000/7500 -JX9/-4.5 -Ba10f5:"Distance along line (km)":/a1000f500:"TWT (ms)":S -O -K >> overlay_107.ps
psbasemap -R -JX -Ba0f0/a0f0nsew -O -K >> overlay_107.ps

# plot the picks
psbasemap -R135810/148065/4000/7500 -JX9/-4.5 -B0/0 -O -K >> overlay_107.ps
psxy -R -JX -B -W3/255/0/0 ../lines/line107/line107.pik -O >> overlay_107.ps

# merge files
psmerge in=section_107.ps translate=0.75,0 in=overlay_107.ps translate=-0.5,0.5 > line107.ps

# view the postscript file
gs -sPAPERSIZE=a4 line107.ps