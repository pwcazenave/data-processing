#!/bin/bash

# Script to surface the JIBS data to fill all the little holes

set -eu

# minmax output
# -R357534/392240/5606386/5651638
west=357534
east=392240
#midx=$(printf "%.0f\n" $(echo "scale=2; $west+(($east-$west)/2)" | bc -l))
midx=375030 # optimised version
midx0=369102 # first third
midx1=380670 # second third
south=5606386
north=5651638
#midy=$(printf "%.0f\n" $(echo "scale=0; $south+(($north-$south)/2)" | bc -l))
midy=5629714 # optimised version
area=-R$west/$east/$south/$north

prefix="HI1157_Block_1_Half_metre_UTM30N"
infile=./raw_data/${prefix}.xyz
gres="-I0.5="

# Blockmean the data
tmpSW=${infile%.*}_blk_SW.xyz
tmpSE=${infile%.*}_blk_SE.xyz
tmpNW=${infile%.*}_blk_NW.xyz
tmpNE=${infile%.*}_blk_NE.xyz

#pbzcat ${infile}.bz2 | blockmean -V -R$west/$midx/$south/$midy $gres > $tmpSW
#pbzcat ${infile}.bz2 | blockmean -V -R$midx/$east/$south/$midy $gres > $tmpSE
#pbzcat ${infile}.bz2 | blockmean -V -R$west/$midx/$midy/$north $gres > $tmpNW
#pbzcat ${infile}.bz2 | blockmean -V -R$midx/$east/$midy/$north $gres > $tmpNE

# Make the grids

# South west
#surface -T0.25 -V $gres -R$west/$midx0/$south/$midy $tmpSW -G./grids/${prefix}_surface_SW.grd
#grdmask -R -NNaN/1/1 -S2 $gres $tmpSW -G./grids/${prefix}_mask_SW.grd
#grdmath ./grids/${prefix}_mask_SW.grd ./grids/${prefix}_surface_SW.grd MUL = ./grids/${prefix}_SW.grd
#rm -f ./grids/${prefix}_mask_SW.grd ./grids/${prefix}_surface_SW.grd
# South middle
#cat $tmpSE $tmpSW | \
#	surface -T0.25 -V $gres -R$midx0/$midx1/$south/$midy -G./grids/${prefix}_surface_SM.grd
#grdmask -R -NNaN/1/1 -S2 $gres $tmpSE $tmpSW -G./grids/${prefix}_mask_SM.grd
#grdmath ./grids/${prefix}_mask_SM.grd ./grids/${prefix}_surface_SM.grd MUL = ./grids/${prefix}_SM.grd
#rm -f ./grids/${prefix}_mask_SM.grd ./grids/${prefix}_surface_SM.grd
# South east
#surface -T0.25 -V $gres -R$midx1/$east/$south/$midy $tmpSE -G./grids/${prefix}_surface_SE.grd
#grdmask -R -NNaN/1/1 -S2 $gres $tmpSE -G./grids/${prefix}_mask_SE.grd
#grdmath ./grids/${prefix}_mask_SE.grd ./grids/${prefix}_surface_SE.grd MUL = ./grids/${prefix}_SE.grd
#rm -f ./grids/${prefix}_mask_SE.grd ./grids/${prefix}_surface_SE.grd

# North west
#surface -T0.25 -V $gres -R$west/$midx0/$midy/$north $tmpNW -G./grids/${prefix}_surface_NW.grd
#grdmask -R -NNaN/1/1 -S2 $gres $tmpNW -G./grids/${prefix}_mask_NW.grd
#grdmath ./grids/${prefix}_mask_NW.grd ./grids/${prefix}_surface_NW.grd MUL = ./grids/${prefix}_NW.grd
#rm -f ./grids/${prefix}_mask_NW.grd ./grids/${prefix}_surface_NW.grd
xyz2grd -V $gres -R$west/$midx0/$midy/$north $tmpNW -G./grids/${prefix}_surface_NW.grd || true
# North middle
cat $tmpNE $tmpNW | \
	surface -T0.25 -V $gres -R$midx0/$midx1/$midy/$north -G./grids/${prefix}_surface_NM.grd
grdmask -R -NNaN/1/1 -S2 $gres $tmpNE $tmpNW -G./grids/${prefix}_mask_NM.grd
grdmath ./grids/${prefix}_mask_NM.grd ./grids/${prefix}_surface_NM.grd MUL = ./grids/${prefix}_NM.grd
rm -f ./grids/${prefix}_mask_NM.grd ./grids/${prefix}_surface_NM.grd
# North east
surface -T0.25 -V $gres -R$midx1/$east/$midy/$north $tmpNE -G./grids/${prefix}_surface_NE.grd
grdmask -R -NNaN/1/1 -S2 $gres $tmpNE -G./grids/${prefix}_mask_NE.grd
grdmath ./grids/${prefix}_mask_NE.grd ./grids/${prefix}_surface_NE.grd MUL = ./grids/${prefix}_NE.grd
rm -f ./grids/${prefix}_mask_NE.grd ./grids/${prefix}_surface_NE.grd

# Combine the grids
grdpaste ./grids/${prefix}_SW.grd ./grids/${prefix}_SM.grd -G./grids/${prefix}_S1.grd
grdpaste ./grids/${prefix}_S1.grd ./grids/${prefix}_SE.grd -G./grids/${prefix}_S.grd
grdpaste ./grids/${prefix}_NW.grd ./grids/${prefix}_NM.grd -G./grids/${prefix}_N1.grd
grdpaste ./grids/${prefix}_N1.grd ./grids/${prefix}_NE.grd -G./grids/${prefix}_N.grd
grdpaste ./grids/${prefix}_S.grd ./grids/${prefix}_N.grd -G./grids/${prefix}_interped.grd

# Tidy up the remnants
#rm -f ./grids/${prefix}_??.grd ./grids/${prefix}_?.grd

# Create an ESRI asc grid
grd2xyz -Ef ./grids/${prefix}_interped.grd | pbzip2 -p4 > ./arc/asc/${prefix}.asc.bz2

