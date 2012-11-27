#!/bin/bash

# Script to prepare various bathymetry sections from GEBCO

area=-15/15/45/65
depths=(5 10 15 20 25 30)
baseres=2.5
gebco=./grids/GEBCO_08.nc

makexyz(){
   grd2xyz -S ${1} > ./modelling/$(basename ${1%.*}).xyz
}

cutgrd(){
   grdsample -I${baseres}k -R${area} -fg $gebco -G${gebco%.*}_${area//\//_}_${baseres}km.grd
   makexyz ${gebco%.*}_${area//\//_}_${baseres}km.grd
}

makedepths(){
   for ((i=0; i<${#depths[@]}; i++)); do
      grdmath ${gebco%.*}_${area//\//_}_${baseres}km.grd ${depths[i]} ADD = \
      ${gebco%.*}_${area//\//_}_${baseres}km_${depths[i]}m.grd
      makexyz ${gebco%.*}_${area//\//_}_${baseres}km_${depths[i]}m.grd
   done
}

#cutgrd
makedepths
