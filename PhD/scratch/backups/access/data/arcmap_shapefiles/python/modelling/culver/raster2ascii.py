import arcpy
import arcgisscripting
import os

# Convert from raster to ascii

gp = arcgisscripting.create()

gp.Workspace = "E:/data/arcmap_shapefiles/culver/historic/sampled/"
outDir = "E:/data/arcmap_shapefiles/culver/historic/sampled/asc/"

rasterList = gp.ListRasters("*")
raster = rasterList.Next()
while raster:
    print raster,outDir+raster+".asc"
    arcpy.RasterToASCII_conversion(raster,outDir+raster+".asc")
    raster = rasterList.Next()

