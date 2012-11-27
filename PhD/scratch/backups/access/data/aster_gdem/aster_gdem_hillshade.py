import arcpy
import arcgisscripting

# Calculate the hillshade for the ASTER GDEM topo data

basedir = "E:/data/aster_gdem/arc/dem/"
raster = "aster_gdem1"
hs = "aster_gdem_hs"

# Get the Spatial analyst licence
arcpy.CheckOutExtension("Spatial")

# Do the hillshade
arcpy.HillShade_3d(basedir + raster, basedir + hs,"140","45","NO_SHADOWS","1")
