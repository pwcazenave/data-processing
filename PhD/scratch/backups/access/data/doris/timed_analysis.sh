#!/bin/bash

# Script to time how long it takes to process a ~17GB ASCII
# file of depths into a series of grids, including subdivision
# for processing in my MATLAB FFT code.

infile=/media/g/tmp/bathy.xyz
base=$(basename $infile .xyz)
grd1m=./grids/${base}_1m.grd
grd20m=./grids/${base}_20m.grd

tl=./timings.log

thinInput(){
	awk '{print $3,$4,$7}' "$1" > "${infile%.*}_thinned.xyz"
}

mk1m(){
	xyz2grd $area -G"${grd1m}" -I1e "${infile%.*}_thinned.xyz"
}

mk20m(){
	xyz2grd $area -G"${grd20m}" -I20e "${infile%.*}_thinned.xyz"
}

time thinInput "$infile" | tee $tl
area=$(minmax -I0.01 ${infile%.*}_thinned.xyz)
time mk1m | tee -a $tl
time mk20m | tee -a $tl


