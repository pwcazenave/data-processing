#!/bin/bash

# Plot the Severn Estuary coastline

pscoast -Df -R-5.5/-2/50.75/52 -W -Ba0.5f0.25/a0.25f0.125WeSn -Jm6.5 -Xc -Yc --BASEMAP_TYPE=plain --D_FORMAT=%lg --PLOT_DEGREE_FORMAT=-DF -W5 -Na -Ggray > ./images/severn_estuary.ps

formats ./images/severn_estuary.ps
