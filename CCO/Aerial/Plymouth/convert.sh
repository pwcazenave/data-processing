#!/bin/bash

# Convert horrible ECW files to nice GeoTIFFs.

gdal=$HOME/Software/bin/gdal_translate
parallel $gdal -q {} -co COMPRESS=JPEG ./geotiffs/{/.}.tiff ::: raw_data/cco*/data/aerial/*.ecw

