#!/bin/bash

# script to plot the bathy, ffts and profiles for the paper in a grid

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 ${outfile%.*}.pdf
   echo -n "and png... "
   gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.png $outfile
   echo "done."
}

gmtset LABEL_FONT_SIZE=18 ANNOT_FONT_SIZE=16
gmtset D_FORMAT=%g
gmtset PAPER_MEDIA=a3

hsbbathy=../hsb_bathy.csv
invbathy=../invincible_bathy.csv
dutchbathy=../dutch_bathy.csv

hsbfft=../hsb_fft.csv
invfft=../invincible_fft.csv
dutchfft=../dutch_fft.csv

hsbtrans=../hsb_profile_ifft.csv
invtrans=../invincible_profile_ifft.csv
dutchtrans=../dutch_profile_ifft.csv

hsbheights=../hsb_heights.csv
invheights=../invincible_heights.csv
dutchheights=../dutch_heights.csv

# areas
# bathy
hsbbarea=$(minmax -I1 $hsbbathy)
invbarea=$(minmax -I1 $invbathy)
dutchbarea=$(minmax -I1 $dutchbathy)
# ffts
hsbprocfftarea=$(minmax -I1 $hsbfft)
invprocfftarea=$(minmax -I1 $invfft)
dutchprocfftarea=$(minmax -I1 $dutchfft)
hsbfftarea=-R-0.15/0.15/-0.15/0.15
hsbfftspatialarea=-R$(echo "scale=10; -1/0.15" | bc -l)/$(echo "scale=10; 1/0.15" | bc -l)/$(echo "scale=10; -1/0.15" | bc -l)/$(echo "scale=10; 1/0.15" | bc -l)
invfftarea=-R-0.3/0.3/-0.3/0.3
invfftspatialarea=-R$(echo "scale=10; -1/0.3" | bc -l)/$(echo "scale=10; 1/0.3" | bc -l)/$(echo "scale=10; -1/0.3" | bc -l)/$(echo "scale=10; 1/0.3" | bc -l)
dutchfftarea=-R-0.3/0.3/-0.3/0.3
dutchfftspatialarea=-R$(echo "scale=10; -1/0.3" | bc -l)/$(echo "scale=10; 1/0.3" | bc -l)/$(echo "scale=10; -1/0.3" | bc -l)/$(echo "scale=10; 1/0.3" | bc -l)
# profiles
hsbtransarea=$(cut -f3,4 -d, $hsbtrans | minmax -I5/0.1)
invtransarea=$(cut -f3,4 -d, $invtrans | minmax -I5/0.1)
dutchtransarea=$(cut -f3,4 -d, $dutchtrans | minmax -I5/0.1)

# projections
hsbproj=-Jx0.02
invproj=-Jx0.04
dutchproj=-Jx0.03
hsbfftfact=4.5
hsbfftproj=-JX$hsbfftfact
invfftfact=4.5
invfftproj=-JX$invfftfact
dutchfftfact=4.5
dutchfftproj=-JX$dutchfftfact
hsbtransproj=-JX10/4.5
invtransproj=-JX10/4.5
dutchtransproj=-JX10/4.5

# intervals
hsbint=100
hsbint2=$(echo "scale=0; $hsbint/2" | bc -l)
hsbdepthint=4
hsbfftint=400
hsbtransint=40
invint=50
invint2=$(echo "scale=0; $invint/2" | bc -l)
invdepthint=1
invfftint=200
invtransint=10
dutchint=100
dutchint2=$(echo "scale=0; $dutchint/2" | bc -l)
dutchdepthint=0.5
dutchfftint=750
dutchtransint=40

# grid resolutions
# bathy
hsbgres=1
invgres=0.5
dutchgres=0.5
# fft - 1/N in each dimension
hsbfftgres=$(minmax -C $hsbbathy | awk '{printf "%.4f", 1/($2-$1)}')/$(minmax -C $hsbbathy | awk '{printf "%.4f", 1/($4-$3)}')
invfftgres=$(minmax -C $invbathy | awk '{printf "%.4f", 1/($2-$1)}')/$(minmax -C $invbathy | awk '{printf "%.4f", 1/($4-$3)}')
dutchfftgres=$(minmax -C $dutchbathy | awk '{printf "%.4f", 1/($2-$1)}')/$(minmax -C $dutchbathy | awk '{printf "%.4f", 1/($4-$3)}')

# grid files
hsbgrd=./grids/$(basename ${hsbbathy%.*}.grd)
hsbgrad=${hsbgrd%.*}_grad.grd
hsbfftgrd=./grids/$(basename ${hsbfft%.*}.grd)
invgrd=./grids/$(basename ${invbathy%.*}.grd)
invgrad=${invgrd%.*}_grad.grd
invfftgrd=./grids/$(basename ${invfft%.*}.grd)
dutchgrd=./grids/$(basename ${dutchbathy%.*}.grd)
dutchgrad=${dutchgrd%.*}_grad.grd
dutchfftgrd=./grids/$(basename ${dutchfft%.*}.grd)

# colour palette files
hsbcpt=./cpts/$(basename ${hsbbathy%.*}.cpt)
hsbfftcpt=./cpts/$(basename ${hsbfft%.*}.cpt)
invcpt=./cpts/$(basename ${invbathy%.*}.cpt)
invfftcpt=./cpts/$(basename ${invfft%.*}.cpt)
dutchcpt=./cpts/$(basename ${dutchbathy%.*}.cpt)
dutchfftcpt=./cpts/$(basename ${dutchfft%.*}.cpt)

# outfile
outfile=./images/combo_results.ps

# some results for use in the symbols
hsblambda=18.55
hsbphi=49.86 # +90
invlambda=10.56
invphi=125.61 # -90
dutchlambda=12.14
dutchphi=81.02 # +90

# make the bathy grids and colour palettes
# bathy
gmtset D_FORMAT=%.2f
xyz2grd $hsbbarea -I$hsbgres $hsbbathy -G$hsbgrd
grdgradient -Nt0.7 -A250 $hsbgrd -G$hsbgrad
#makecpt -T$(cut -f3 -d, $hsbbathy | minmax -C | awk '{print $1"/"$2}')/0.01 -Cgray -Z > $hsbcpt
makecpt $(cut -f3 -d, $hsbbathy | minmax -T0.1) -Cgray -Z > $hsbcpt
xyz2grd $invbarea -I$invgres $invbathy -G$invgrd
grdgradient -Nt0.7 -A315 $invgrd -G$invgrad
makecpt $(cut -f3 -d, $invbathy | minmax -T0.1) -Cgray -Z -I > $invcpt
xyz2grd $dutchbarea -I$dutchgres $dutchbathy -G$dutchgrd
grdgradient -Nt0.7 -A270 $dutchgrd -G$dutchgrad
makecpt $(cut -f3 -d, $dutchbathy | minmax -T0.1) -Cgray -Z > $dutchcpt
# fft
gmtset D_FORMAT=%g
xyz2grd $hsbprocfftarea -I$hsbfftgres $hsbfft -G$hsbfftgrd
xyz2grd $invprocfftarea -I$invfftgres $invfft -G$invfftgrd
xyz2grd $dutchprocfftarea -I$dutchfftgres $dutchfft -G$dutchfftgrd
makecpt -T$(cut -f3 -d, $hsbfft | minmax -C | cut -f2 | awk '{print $1*-0.1}')/$(cut -f3 -d, $hsbfft | minmax -C | cut -f2)/$(cut -f3 -d, $hsbfft | minmax -C | cut -f2 | awk '{print ($1/100)*0.9'}) -Cgray -I -Z > $hsbfftcpt
makecpt -T$(cut -f3 -d, $invfft | minmax -C | cut -f2 | awk '{print $1*-0.1}')/$(cut -f3 -d, $invfft | minmax -C | cut -f2)/$(cut -f3 -d, $invfft | minmax -C | cut -f2 | awk '{print ($1/100)*0.9'}) -Cgray -I -Z > $invfftcpt
makecpt -T$(cut -f3 -d, $dutchfft | minmax -C | cut -f2 | awk '{print $1*-0.1}')/$(cut -f3 -d, $dutchfft | minmax -C | cut -f2)/$(cut -f3 -d, $dutchfft | minmax -C | cut -f2 | awk '{print ($1/100)*0.9'}) -Cgray -I -Z > $dutchfftcpt

# plot the bathy
gmtset D_FORMAT=%.0f
psbasemap $dutchbarea $dutchproj -B0 -K -X3 -Y4 > $outfile # default position
grdimage $dutchbarea $dutchproj $dutchgrd -I$dutchgrad -C$dutchcpt -O -K \
   -Ba${dutchint}g${dutchint2}/a${dutchint2}g${dutchint2}WeSn >> $outfile
gmtset D_FORMAT=%g
psscale -D8.75/1.8/3/0.25 -I -B$dutchdepthint -C$dutchcpt -O -K >> $outfile
# add in transect lines
psxy $dutchbarea $dutchproj $dutchtrans -W8/black -O -K >> $outfile
pstext $dutchbarea $dutchproj -N -O -K -D0.3/0.4 -WwhiteO0,white << TRANS >> $outfile
$(awk -F, '{print $1,$2}' $dutchtrans | head -n1) 16 0 0 1 O
TRANS
pstext $dutchbarea $dutchproj -N -O -K -D-0.75/-0.75 -WwhiteO0,white << TRANS >> $outfile
$(awk -F, '{print $1,$2}' $dutchtrans | tail -n1) 16 0 0 1 O'
TRANS
gmtset D_FORMAT=%.0f
psbasemap $invbarea $invproj -B0 -O -K -X2 -Y6 >> $outfile
grdimage $invbarea $invproj $invgrd -I$invgrad -C$invcpt -O -K \
   -Ba${invint}g${invint2}/a${invint}g${invint2}WeSn >> $outfile
gmtset D_FORMAT=%g
psscale -D5/2.7/-3/0.25 -I -B$invdepthint -C$invcpt -O -K >> $outfile
# add in transect lines
psxy $invbarea $invproj $invtrans -W8/black -O -K >> $outfile
pstext $invbarea $invproj -N -O -K -D0.3/0.1 -WwhiteO0,white << TRANS >> $outfile
$(awk -F, '{print $1,$2}' $invtrans | head -n1) 16 0 0 1 N
TRANS
pstext $invbarea $invproj -N -O -K -D-0.1/0.3 -WwhiteO0,white << TRANS >> $outfile
$(awk -F, '{print $1,$2}' $invtrans | tail -n1) 16 0 0 1 N'
TRANS
gmtset D_FORMAT=%.0f
psbasemap $hsbbarea $hsbproj -B0 -O -K -X-0.3 -Y7.5 >> $outfile
grdimage $hsbbarea $hsbproj $hsbgrd -I$hsbgrad -C$hsbcpt -O -K \
   -Ba${hsbint}g${hsbint2}/a${hsbint}g${hsbint2}WeSn >> $outfile
gmtset D_FORMAT=%g
psscale -D5.8/2.5/3/0.25 -I -B$hsbdepthint -C$hsbcpt -O -K >> $outfile
# add in transect lines
psxy $hsbbarea $hsbproj $hsbtrans -W8/black -O -K >> $outfile
pstext $hsbbarea $hsbproj -N -O -K -D0.3/-0.5 -WwhiteO0,white << TRANS >> $outfile
$(awk -F, '{print $1,$2}' $hsbtrans | head -n3) 16 0 0 1 M
TRANS
pstext $hsbbarea $hsbproj -N -O -K -D0.2/-0.5 -WwhiteO0,white << TRANS >> $outfile
$(awk -F, '{print $1,$2}' $hsbtrans | tail -n1) 16 0 0 1 M'
TRANS

# ffts
psbasemap $dutchfftarea $dutchfftproj -B0 -O -K -X12 -Y-13.75 >> $outfile
grdimage $dutchfftarea $dutchfftproj $dutchfftgrd -C$dutchfftcpt -O -K \
   -Ba0.2g0.1:"kx (m@+-1@+)":/a0.2g0.1:"ky (m@+-1@+)":WeSn >> $outfile
echo "0 0 $dutchphi $(echo "scale=2; 100*(1/($dutchlambda/$dutchfftfact))" | bc -l)" | psxy $dutchfftarea $dutchfftproj -SV0/0/0 -O -K -W5 -Gblack >> $outfile
echo "0 0" | psxy $dutchfftspatialarea $dutchfftproj -Sc$(echo "scale=2; 0.5*$dutchlambda/$dutchfftfact" | bc -l) -O -K -W8 >> $outfile
psscale -D5.25/2.25/3/0.25 -B$dutchfftint:"Power": -C$dutchfftcpt -O -K >> $outfile
psbasemap $invfftarea $invfftproj -B0 -O -K -Y7 >> $outfile
grdimage $invfftarea $invfftproj $invfftgrd -C$invfftcpt -O -K \
   -Ba0.2g0.1:"kx (m@+-1@+)":/a0.2g0.1:"ky (m@+-1@+)":WeSn >> $outfile
echo "0 0 $invphi $(echo "scale=2; 100*(1/($invlambda/$invfftfact))" | bc -l)" | psxy $invfftarea $invfftproj -SV0/0/0 -O -K -W5 -Gblack >> $outfile
echo "0 0" | psxy $invfftspatialarea $invfftproj -Sc$(echo "scale=2; 0.7*$invlambda/$invfftfact" | bc -l) -O -K -W8 >> $outfile
psscale -D5.25/2.25/3/0.25 -B$invfftint:"Power": -C$invfftcpt -O -K >> $outfile
psbasemap $hsbfftarea $hsbfftproj -B0 -O -K -Y7 >> $outfile
grdimage $hsbfftarea $hsbfftproj $hsbfftgrd -C$hsbfftcpt -O -K \
   -Ba0.1g0.05:"kx (m@+-1@+)":/a0.1g0.05:"ky (m@+-1@+)":WeSn >> $outfile
echo "0 0 $hsbphi $(echo "scale=2; 100*(1/($hsblambda/$hsbfftfact))" | bc -l)" | psxy $hsbfftarea $hsbfftproj -SV0/0/0 -O -K -W5 -Gblack >> $outfile
echo "0 0" | psxy $hsbfftspatialarea $hsbfftproj -Sc$(echo "scale=2; 0.4*$hsblambda/$hsbfftfact" | bc -l) -O -K -W8 >> $outfile
psscale -D5.25/2.25/3/0.25 -B$hsbfftint:"Power": -C$hsbfftcpt -O -K >> $outfile

# add in the profiles
psbasemap $dutchtransarea $dutchtransproj -X9 -Y-14 -O -K \
   -Ba$dutchtransint:"Distance along line (m)":/a0.2:"Height (m)":wESn >> $outfile
cut -f3,4 -d, $dutchtrans | psxy $dutchtransarea $dutchtransproj -W8 -O -K >> $outfile
cut -f1,8 -d, $dutchheights | psxy $dutchtransarea $dutchtransproj -W8,. -O -K >> $outfile
awk -F, '{print $1,$8*-1}' $dutchheights | \
   psxy $dutchtransarea $dutchtransproj -W8,. -O -K >> $outfile
pstext $dutchtransarea $dutchtransproj -N -O -K -D0.1/0.1 << LABEL >> $outfile
0 $(echo $dutchtransarea | cut -f3 -d'/') 16 0 0 1 O
LABEL
pstext $dutchtransarea $dutchtransproj -N -O -K -D-0.6/0.1 << LABEL >> $outfile
$(echo $dutchtransarea | cut -f2 -d'/') $(echo $dutchtransarea | cut -f3 -d'/') 16 0 0 1 O'
LABEL
psbasemap $invtransarea $invtransproj -Y7 -O -K \
   -Ba$invtransint:"Distance along line (m)":/a0.1:"Height (m)":wESn >> $outfile
cut -f3,4 -d, $invtrans | psxy $invtransarea $invtransproj -W8 -O -K >> $outfile
cut -f1,8 -d, $invheights | psxy $invtransarea $invtransproj -W8,. -O -K >> $outfile
awk -F, '{print $1,$8*-1}' $invheights | \
   psxy $invtransarea $invtransproj -W8,. -O -K >> $outfile
pstext $invtransarea $invtransproj -N -O -K -D0.1/0.1 << LABEL >> $outfile
0 $(echo $invtransarea | cut -f3 -d'/') 16 0 0 1 N
LABEL
pstext $invtransarea $invtransproj -N -O -K -D-0.6/0.1 << LABEL >> $outfile
$(echo $invtransarea | cut -f2 -d'/') $(echo $invtransarea | cut -f3 -d'/') 16 0 0 1 N'
LABEL
psbasemap $hsbtransarea $hsbtransproj -Y7 -O -K \
   -Ba$hsbtransint:"Distance along line (m)":/a0.2:"Height (m)":wESn >> $outfile
cut -f3,4 -d, $hsbtrans | psxy $hsbtransarea $hsbtransproj -W8 -O -K >> $outfile
cut -f1,8 -d, $hsbheights | psxy $hsbtransarea $hsbtransproj -W8,. -O -K >> $outfile
awk -F, '{print $1,$8*-1}' $hsbheights | \
   psxy $hsbtransarea $hsbtransproj -W8,. -O -K >> $outfile
pstext $hsbtransarea $hsbtransproj -N -O -K -D0.1/0.1 << LABEL >> $outfile
0 $(echo $hsbtransarea | cut -f3 -d'/') 16 0 0 1 M
LABEL
pstext $hsbtransarea $hsbtransproj -N -O -D-0.7/0.1 << LABEL >> $outfile
$(echo $hsbtransarea | cut -f2 -d'/') $(echo $hsbtransarea | cut -f3 -d'/') 16 0 0 1 M'
LABEL


formats $outfile

