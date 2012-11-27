#!/bin/bash

# Script to plot the locations of the BODC, SHOM, NHS and North Sea Tidal
# Data calibration locations.

# Tides
ntslf=./raw_data/calibration/tides/station_locations.csv
shom=./raw_data/calibration/tides/shom_tide_stations.csv
nhs=./raw_data/calibration/tides/locations_model.csv
cefas=./raw_data/calibration/tides/offshore_awacs_tides.csv
ukho=./raw_data/calibration/tides/ukho_tide_stations.csv
nstd=./raw_data/calibration/tides/north_sea_tidal_data_proper.csv
eec=./raw_data/calibration/tides/eec_gauge_location_2007.csv

# Currents
bodc1=./raw_data/calibration/currents/new_ones.csv
#bodc2=./raw_data/calibration/currents/uk_moored_current_meters_with_metadata.csv
bodc2=./raw_data/calibration/currents/metadata_all_duration.csv

# Data I actually used
tides=./raw_data/tide_station_locations.xy
currents=./raw_data/current_station_locations.xy

area=-R-17/17/43/67
proj=-Jm0.55

outfile=./images/$(basename ${0%.*}).ps

# Reset GMT setup
gmtdefaults -D > .gmtdefaults4

gmtset BASEMAP_TYPE=plain PLOT_DEGREE_FORMAT=F

# Put the coastline in
psbasemap $area $proj -Ba5f1/a5f1WeSn -K -X1.5 -Y1 -P > $outfile
pscoast $area $proj -Dhigh -Gdarkgrey -W2,black -A50 -N1/2 -N3 -O -K >> $outfile

# Add in the tidal data
awk -F"," '{print $2,$1}' $ntslf | \
    psxy -H1 $area $proj -Sc0.2 -Gblack -O -K >> $outfile
awk -F"," '{print $1,$2}' $shom | \
    psxy -H1 $area $proj -Sc0.2 -Gblack -O -K >> $outfile
awk -F"," '{print $1,$2}' $nhs | \
    psxy -H1 $area $proj -Sc0.2 -Gblack -O -K >> $outfile
awk -F"," '{print $3,$4}' $cefas | \
    psxy -H1 $area $proj -Sc0.2 -Gblack -O -K >> $outfile
awk -F"," '{print $2,$1}' $ukho | \
    psxy -H1 $area $proj -Sc0.2 -Gblack -O -K >> $outfile
awk -F"," '{print $1,$2}' $nstd | \
    psxy -H1 $area $proj -Sc0.2 -Gblack -O -K >> $outfile
# EEC Gauge is in eastings and northings...
#awk -F"," '{print $1,$2}' $eec | \
#    psxy -H1 $area $proj -Sc0.2 -Gblack -O -K >> $outfile

# Now the currents, filtering out those whose duration is less than a spring-
# neap tidal cycle (~14.5 days).
awk -F"," '{print $2,$1}' $bodc1 | \
    psxy -H1 $area $proj -St0.2 -Wblack -O -K >> $outfile
awk -F"," '{if ($6>14.5) print $3,$2}' $bodc2 | \
    psxy -H1 $area $proj -St0.2 -Wblack -O -K >> $outfile

# Add the locations I actually used
psxy -H1 $area $proj -Sc0.2 -Gorange -O -K $tides >> $outfile
psxy -H1 $area $proj -St0.2 -Ggreen -O -K $currents >> $outfile

# Add model domain
psxy $area $proj -L -A -W5,black,- -O -K << DOMAIN >> $outfile
-15 45
-15 65
15 65
15 45
DOMAIN

# Box around the key
psxy $area $proj -L -A -Ggray -O -K << KEY >> $outfile
-13.9 65.7
-13.9 66.8
-9 66.8
-9 65.7
KEY

# Add a key
psxy $area $proj -O -K -Sc0.2 -Gblack << SYMBOLS >> $outfile
-13.5 66.5
SYMBOLS
psxy $area $proj -O -K -St0.2 -Gwhite -Wblack << SYMBOLS >> $outfile
-13.5 66
SYMBOLS

pstext $area $proj -D0.4/-0.15 -O << LABELS >> $outfile
-13.5 66.5 14 0 0 1 Tides
-13.5 66 14 0 0 1 Currents
LABELS



formats $outfile
