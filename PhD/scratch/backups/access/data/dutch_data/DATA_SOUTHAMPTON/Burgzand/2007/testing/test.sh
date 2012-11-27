#!/bin/bash

DATE=$(date +%y-%d-%m_%H%M%S)
area=-R125129/125160/562167/562197
gres=-I0.5

gmtset D_FORMAT=%g

makecpt -T-7.9/-6.5/0.1 -Z > test.cpt

grdmask -F $area $gres -H1 -NNaN/1/1 -S0.5 -Gtest.grd test.csv

echo "x,y,z" > ./grdmask_edge.csv
grd2xyz test.grd -S | tr "\t" "," >> ./grdmask_edge.csv
xyz2grd $area $gres -Gdata.grd -F test.csv

grdimage $area -Jx0.5 test.grd -P -Xc -Yc -Ctest.cpt -B10WeSn > test.ps
grdimage $area -Jx0.5 data.grd -P -Xc -Yc -Ctest.cpt -B10WeSn > data.ps

ps2pdf test.ps
ps2pdf data.ps
