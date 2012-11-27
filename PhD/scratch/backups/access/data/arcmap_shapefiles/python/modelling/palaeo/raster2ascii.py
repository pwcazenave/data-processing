import arcpy
import arcgisscripting
import os

# Convert from raster to ascii

gp = arcgisscripting.create()

gp.Workspace = "C:/Users/goosin/Desktop/Bradley_GIA_Data/GIS/Palaeogeography/"
outDir = "C:/Users/goosin/Desktop/Bradley_GIA_Data/GIS/Palaeogeography/asc/"

rasterList = gp.ListRasters("*")
raster = rasterList.Next()
while raster:
    print raster,outDir+raster+".asc"
    arcpy.RasterToASCII_conversion(raster,outDir+raster+".asc")
    raster = rasterList.Next()

