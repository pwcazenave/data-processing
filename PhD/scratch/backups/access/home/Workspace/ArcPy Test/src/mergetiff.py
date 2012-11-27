""" Takes a series of arguments (GeoTIFF filenames) and outputs a
merged GeoTIFF. Works with ASTER-GDEM data only.

Pierre Cazenave 2011/04/08 pwc101@soton.ac.uk

"""

import arcpy
##import os
##import sys
##
##def getRows(files):
##
##    names = []
##    norths = []
##    easts = []
##
##    for i, currentName in enumerate(files):
##        print currentName
##        names[i] = os.path.split(currentName)
##        print names[i]
##    
##getRows(sys.argv[1])
    
# Set of rows which will each be merged in turn
files16="ASTGTM_N67E016_dem.tif;ASTGTM_N67E017_dem.tif;ASTGTM_N67E018_dem.tif;ASTGTM_N67E019_dem.tif;ASTGTM_N67E020_dem.tif;"
files17="ASTGTM_N68E016_dem.tif;ASTGTM_N68E017_dem.tif;ASTGTM_N68E018_dem.tif;ASTGTM_N68E019_dem.tif;ASTGTM_N68E020_dem.tif;"
files18="ASTGTM_N69E016_dem.tif;ASTGTM_N69E017_dem.tif;ASTGTM_N69E018_dem.tif;ASTGTM_N69E019_dem.tif;ASTGTM_N69E020_dem.tif;"
#files19="E:/data/aster_gdem/raw_data/dem/ASTGTM_N19E045_dem.tif;E:/data/aster_gdem/raw_data/dem/ASTGTM_N19E046_dem.tif;E:/data/aster_gdem/raw_data/dem/ASTGTM_N19E047_dem.tif;E:/data/aster_gdem/raw_data/dem/ASTGTM_N19E048_dem.tif;E:/data/aster_gdem/raw_data/dem/ASTGTM_N19E049_dem.tif;E:/data/aster_gdem/raw_data/dem/ASTGTM_N19E050_dem.tif;E:/data/aster_gdem/raw_data/dem/ASTGTM_N19E051_dem.tif"
#files20="E:/data/aster_gdem/raw_data/dem/ASTGTM_N20E045_dem.tif;E:/data/aster_gdem/raw_data/dem/ASTGTM_N20E046_dem.tif;E:/data/aster_gdem/raw_data/dem/ASTGTM_N20E047_dem.tif;E:/data/aster_gdem/raw_data/dem/ASTGTM_N20E048_dem.tif;E:/data/aster_gdem/raw_data/dem/ASTGTM_N20E049_dem.tif"

# Run each of the filesets
arcpy.MosaicToNewRaster_management(files16,"dem","n67","#","16_BIT_SIGNED","#","1","#","#")
arcpy.MosaicToNewRaster_management(files17,"dem","n68","#","16_BIT_SIGNED","#","1","#","#")
arcpy.MosaicToNewRaster_management(files18,"dem","n69","#","16_BIT_SIGNED","#","1","#","#")
#arcpy.MosaicToNewRaster_management(files19,"E:/data/aster_gdem/raw_data/dem","n19","#","16_BIT_SIGNED","#","1","#","#")
#arcpy.MosaicToNewRaster_management(files20,"E:/data/aster_gdem/raw_data/dem","n20","#","16_BIT_SIGNED","#","1","#","#")

# Mosaic each of those results
outputs="dem/n67;dem/n68;dem/n69;"
arcpy.MosaicToNewRaster_management(outputs,"dem/","aster_gdem","#","16_BIT_SIGNED","#","1","#","#")
