#!/bin/csh -f

# script to format the output from all the various sources so that they're the
# same length

##----------------------------------------------------------------------------##

set nh_obs=./raw_data/2005NHA.txt
set do_obs=./raw_data/2005DOV.txt
set ha_pre=./raw_data/hastings_05-06_formatted.txt
set nh_pre=./raw_data/newhaven_05-06_formatted.txt

awk '/2005\/09/ {print $4}' $nh_obs | tr -d "TN" > ./raw_data/newhaven.dat
awk '/2005\/09/ {print $4}' $do_obs | tr -d "TN" > ./raw_data/dover.dat
awk '/2005-09/ {print $2}' $ha_pre > ./raw_data/hastings.dat
awk '/2005-09/ {print $2}' $nh_pre > ./raw_data/w_newhaven.dat

tr -d "TN" < $nh_obs | awk '/2005\/09/ {print $2"T"$3}' | tr "/" "-" > ./raw_data/time.dat

##----------------------------------------------------------------------------##
