#!/bin/bash

# convert the UTM eastings and northings from the PCTrans output to lat longs

gmtset D_FORMAT=%.9f

infile=./locations_all.csv

awk -F"," 'NR>1 {print $3,$4}' $infile | \
   mapproject -R3.53/4.07/52.58/52.96 -Ju31/1:1 -I -F -C > ${infile%.*}_latlong.txt
