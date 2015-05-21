#!/bin/bash

# Script to merge each day's data into a single coherent time series.

set -u

# Range of years for which to download data.
years=({1990..2000})
years=(1990)
months=({1..12})

for y in ${years[@]}; do
    for m in ${months[@]}; do
        days=$(date -d "$y/$m/01 + 1 month - 1 day" +%d)
        for d in $(seq 1 $days); do
            dir=$(printf %04d/%04d%02d/%04d%02d%02d $y $y $m $y $m $d)
            echo -en "\rWorking on $(printf %04d/%02d/%02d $y $m $d) "
            first=$dir/$(printf pgbh0?.gdas.%04d%02d%02d00.nc $y $m $d)
            second=$dir/$(printf pgbh0?.gdas.%04d%02d%02d06.nc $y $m $d)
            third=$dir/$(printf pgbh0?.gdas.%04d%02d%02d12.nc $y $m $d)
            fourth=$dir/$(printf pgbh0?.gdas.%04d%02d%02d18.nc $y $m $d)
            out=$dir/$(printf pgbh.gdas.%04d%02d%02d.nc $y $m $d)
            ncrcat $first $second $third $fourth $out
            echo "done."
        done
    done
done
