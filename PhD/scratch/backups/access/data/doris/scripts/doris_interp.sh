#!/bin/bash

# Script to interpolate the Doris data to fill the odd gaps in the
# eastern area (mainly).

set -eu

gmtdefaults -D > .gmtdefaults4

dotwait(){
	until [ -e "$1" ]; do
		i=0
		while [ "$i" -lt "3" ]; do
			echo -n "."
			sleep 1
			i=$(($i+1))
		done
		echo -en "\b\b\b   \b\b\b"
	done
}

prefix=/local/pwc101/grids/
infile=/local/pwc101/DORISall1m.txt

west=355220
west1=367200
east1=380500
east2=393930
east=407300
south=61040
south1=72615
north=84190

area0=-R$west/$west1/$south/$south1
area1=-R$west1/$east1/$south/$south1
area2=-R$east1/$east2/$south/$south1
area3=-R$east2/$east/$south/$south1
area4=-R$west/$west1/$south1/$north
area5=-R$west1/$east1/$south1/$north
area6=-R$east1/$east2/$south1/$north
area7=-R$east2/$east/$south1/$north

#echo -n "Creating masks: 00"
#grdmask $area0 -H1 -I1 -S2 -NNaN/1/1 $infile -G$prefix/DORISall1m_interp_2m_00_mask.grd &
#dotwait $prefix/DORISall1m_interp_2m_00_mask.grd
#echo -n ", 01"
#grdmask $area1 -H1 -I1 -S2 -NNaN/1/1 $infile -G$prefix/DORISall1m_interp_2m_01_mask.grd &
#dotwait $prefix/DORISall1m_interp_2m_01_mask.grd
#echo -n ", 02"
#grdmask $area2 -H1 -I1 -S2 -NNaN/1/1 $infile -G$prefix/DORISall1m_interp_2m_02_mask.grd &
#dotwait $prefix/DORISall1m_interp_2m_02_mask.grd
#echo -n ", 03"
#grdmask $area3 -H1 -I1 -S2 -NNaN/1/1 $infile -G$prefix/DORISall1m_interp_2m_03_mask.grd &
#dotwait $prefix/DORISall1m_interp_2m_03_mask.grd
#echo -n ", 04"
#grdmask $area4 -H1 -I1 -S2 -NNaN/1/1 $infile -G$prefix/DORISall1m_interp_2m_04_mask.grd &
#dotwait $prefix/DORISall1m_interp_2m_04_mask.grd
#echo -n ", 05"
#grdmask $area5 -H1 -I1 -S2 -NNaN/1/1 $infile -G$prefix/DORISall1m_interp_2m_05_mask.grd &
#dotwait $prefix/DORISall1m_interp_2m_05_mask.grd
#echo -n ", 06"
#grdmask $area6 -H1 -I1 -S2 -NNaN/1/1 $infile -G$prefix/DORISall1m_interp_2m_06_mask.grd &
#dotwait $prefix/DORISall1m_interp_2m_06_mask.grd
#echo -n "and 07"
#grdmask $area7 -H1 -I1 -S2 -NNaN/1/1 $infile -G$prefix/DORISall1m_interp_2m_07_mask.grd &
#dotwait $prefix/DORISall1m_interp_2m_07_mask.grd
#echo "... done."

echo -n "Surfacing: 00"
surface -H1 -I1 -S2 -T0.25 $area0 $infile -G$prefix/DORISall1m_interp_2m_00.grd 2> /dev/null &
dotwait $prefix/DORISall1m_interp_2m_00.grd
echo -n ", 01"
surface -H1 -I1 -S2 -T0.25 $area1 $infile -G$prefix/DORISall1m_interp_2m_01.grd 2> /dev/null &
dotwait $prefix/DORISall1m_interp_2m_01.grd
echo -n ", 02"
surface -H1 -I1 -S2 -T0.25 $area2 $infile -G$prefix/DORISall1m_interp_2m_02.grd 2> /dev/null &
dotwait $prefix/DORISall1m_interp_2m_02.grd
echo -n ", 03"
surface -H1 -I1 -S2 -T0.25 $area3 $infile -G$prefix/DORISall1m_interp_2m_03.grd 2> /dev/null &
dotwait $prefix/DORISall1m_interp_2m_03.grd
echo -n ", 04"
surface -H1 -I1 -S2 -T0.25 $area4 $infile -G$prefix/DORISall1m_interp_2m_04.grd 2> /dev/null &
dotwait $prefix/DORISall1m_interp_2m_04.grd
echo -n ", 05"
surface -H1 -I1 -S2 -T0.25 $area5 $infile -G$prefix/DORISall1m_interp_2m_05.grd 2> /dev/null &
dotwait $prefix/DORISall1m_interp_2m_05.grd
echo -n ", 06"
surface -H1 -I1 -S2 -T0.25 $area6 $infile -G$prefix/DORISall1m_interp_2m_06.grd 2> /dev/null &
dotwait $prefix/DORISall1m_interp_2m_06.grd
echo -n "and 07"
surface -H1 -I1 -S2 -T0.25 $area7 $infile -G$prefix/DORISall1m_interp_2m_07.grd 2> /dev/null &
dotwait $prefix/DORISall1m_interp_2m_07.grd
echo "... done."

echo -n "Applying the masks: 00"
grdmath $prefix/DORISall1m_interp_2m_00.grd $prefix/DORISall1m_interp_2m_00_mask.grd \
	MUL = $prefix/DORISall1m_interp_2m_00_masked.grd &
dotwait $prefix/DORISall1m_interp_2m_00_masked.grd
echo -n ", 01"
grdmath $prefix/DORISall1m_interp_2m_01.grd $prefix/DORISall1m_interp_2m_01_mask.grd \
	MUL = $prefix/DORISall1m_interp_2m_01_masked.grd &
dotwait $prefix/DORISall1m_interp_2m_01_masked.grd
echo -n ", 02"
grdmath $prefix/DORISall1m_interp_2m_02.grd $prefix/DORISall1m_interp_2m_02_mask.grd \
	MUL = $prefix/DORISall1m_interp_2m_02_masked.grd &
dotwait $prefix/DORISall1m_interp_2m_02_masked.grd
echo -n ", 03"
grdmath $prefix/DORISall1m_interp_2m_03.grd $prefix/DORISall1m_interp_2m_03_mask.grd \
	MUL = $prefix/DORISall1m_interp_2m_03_masked.grd &
dotwait $prefix/DORISall1m_interp_2m_03_masked.grd
echo -n ", 04"
grdmath $prefix/DORISall1m_interp_2m_04.grd $prefix/DORISall1m_interp_2m_04_mask.grd \
	MUL = $prefix/DORISall1m_interp_2m_04_masked.grd &
dotwait $prefix/DORISall1m_interp_2m_04_masked.grd
echo -n ", 05"
grdmath $prefix/DORISall1m_interp_2m_05.grd $prefix/DORISall1m_interp_2m_05_mask.grd \
	MUL = $prefix/DORISall1m_interp_2m_05_masked.grd &
dotwait $prefix/DORISall1m_interp_2m_05_masked.grd
echo -n ", 06"
grdmath $prefix/DORISall1m_interp_2m_06.grd $prefix/DORISall1m_interp_2m_06_mask.grd \
	MUL = $prefix/DORISall1m_interp_2m_06_masked.grd &
dotwait $prefix/DORISall1m_interp_2m_06_masked.grd
echo -n "and 07"
grdmath $prefix/DORISall1m_interp_2m_07.grd $prefix/DORISall1m_interp_2m_07_mask.grd \
	MUL = $prefix/DORISall1m_interp_2m_07_masked.grd &
dotwait $prefix/DORISall1m_interp_2m_07_masked.grd
echo "... done."

echo -n "Merging masked files 00 and 01"
grdpaste $prefix/DORISall1m_interp_2m_00_masked.grd $prefix/DORISall1m_interp_2m_01_masked.grd \
	-G$prefix/DORISall1m_interp_2m_00-01.grd &
dotwait $prefix/DORISall1m_interp_2m_00-01.grd
echo -n ", file 00-01 and 02"
grdpaste $prefix/DORISall1m_interp_2m_00-01.grd $prefix/DORISall1m_interp_2m_02_masked.grd \
	-G$prefix/DORISall1m_interp_2m_00-01-02.grd &
dotwait $prefix/DORISall1m_interp_2m_00-01-02.grd
echo -n ", file 00-01-02 and 03"
grdpaste $prefix/DORISall1m_interp_2m_00-01-02.grd $prefix/DORISall1m_interp_2m_03_masked.grd \
	-G$prefix/DORISall1m_interp_2m_00-01-02-03.grd
dotwait $prefix/DORISall1m_interp_2m_00-01-02-03.grd
echo "... done."

echo -n "Merging masked files 04 and 05"
grdpaste $prefix/DORISall1m_interp_2m_04.grd $prefix/DORISall1m_interp_2m_05_masked.grd \
	-G$prefix/DORISall1m_interp_2m_04-05.grd
dotwait $prefix/DORISall1m_interp_2m_04-05.grd
echo -n ", file 04-05 and 06"
grdpaste $prefix/DORISall1m_interp_2m_04-05.grd $prefix/DORISall1m_interp_2m_06_masked.grd \
	-G$prefix/DORISall1m_interp_2m_04-05-06.grd
dotwait $prefix/DORISall1m_interp_2m_04-05-06.grd
echo -n ", file 04-05-06 and 07"
grdpaste $prefix/DORISall1m_interp_2m_04-05-06.grd $prefix/DORISall1m_interp_2m_07_masked.grd \
	-G$prefix/DORISall1m_interp_2m_04-05-06-07.grd
dotwait $prefix/DORISall1m_interp_2m_04-05-06-07.grd
echo "... done."

echo -n "Merging file 00-01-02-04 and 04-05-06-07"
grdpaste $prefix/DORISall1m_interp_2m_00-01-02-03.grd $prefix/DORISall1m_interp_2m_04-05-06-07.grd \
	-G$prefix/DORISall1m_interp_2m_bigarea.grd
dotwait $prefix/DORISall1m_interp_2m_bigarea.grd
echo "... done."

echo -n "Clipping to original area"
grdcut $(grdinfo -I1 $HOME/scratch/jkd/Dorset/DORISall1m.grd) $prefix/DORISall1m_interp_2m_bigarea.grd \
	-G$prefix/DORISall1m_interp_2m.grd
dotwait $prefix/DORISall1m_interp_2m.grd
echo "... done."

#echo -n "Exporting to ESRI ASCII"
#grd2xyz -Ef $prefix/DORISall1m_interp_2m.grd > $prefix/DORISall1m_interp_2m.asc
#dotwait $prefix/DORISall1m_interp_2m.asc
#echo "... done."
