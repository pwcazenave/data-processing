#!/bin/bash

# Plot the Severn Estuary coastline

pscoast -Df -R-6/3/48.5/51.25 -W -Ba1f0.5/a0.5f0.25WeSn -A1 -Jm2.86 -X2.5 -Yc --BASEMAP_TYPE=plain --D_FORMAT=%lg --PLOT_DEGREE_FORMAT=DF -W5 -Na -Ggray > ./images/english_channel.ps

formats ./images/english_channel.ps
