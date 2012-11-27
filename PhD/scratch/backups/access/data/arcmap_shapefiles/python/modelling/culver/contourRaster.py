# Import system modules
import os
import arcgisscripting
import arcpy

basedir = "E:/data/arcmap_shapefiles/culver/bathy/"
outdir = "E:/data/arcmap_shapefiles/culver/bathy/contours/3.5m/"
rasList = '2008_10m_int','2009_10m_int','2010_10m_int'
oldRasList = '032000','0899','091999','1795','1831','1848','1886','1925','1939','1961','1965','1979','1989'

# The modern data
for ras in rasList:
    if '2010' in ras:
        arcpy.ContourList_3d(ras,outdir+ras+".shp","-7")
    else:
        arcpy.ContourList_3d(ras,outdir+ras+".shp","7")

# The old data
for ras in oldRasList:
    arcpy.ContourList_3d("L389_"+ras,outdir+"L389"+ras+".shp","7")

