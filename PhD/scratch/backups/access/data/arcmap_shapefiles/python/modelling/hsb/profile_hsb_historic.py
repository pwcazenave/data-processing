import arcpy
import arcgisscripting
from arcpy import env
from arcpy.sa import *

# Extract all the depths for each historic surface and convert to
# ASCII raster

allYears = ['1988','1993','1994','1995','1996','1998','1999','2000','2001','2002','2003','2004','2005','2006','2007','2008','2009','2010']
polylineSample1 = "E:/data/arcmap_shapefiles/modelling/hsb/bathy/common_profile_north.shp"
polylineSample2 = "E:/data/arcmap_shapefiles/modelling/hsb/bathy/common_profile_south.shp"

for currentYear in allYears:
    print "Working on " + currentYear + "...",

    if '1988' in currentYear:
        basedir = "E:/data/aggregates/hsb/" + currentYear + "/bathy/arc/raster/"
        raster = basedir + "/" + currentYear + "_25m_i_c"
    elif '2004' in currentYear:
        basedir = "E:/data/aggregates/hsb/" + currentYear + "/bathy/arc/raster/"
        raster = basedir + "/" + currentYear
    elif '2005' in currentYear:
        basedir = "E:/data/aggregates/hsb/" + currentYear + "/bathy/"
        raster = basedir + "/" + "hsb_1m_pos"
    elif '2006' in currentYear:
        basedir = "E:/data/aggregates/hsb/" + currentYear + "/arc/raster/"
        raster = basedir + "/" + "hsb_" + currentYear + "_osgb"
    elif '2007' in currentYear:
        basedir = "E:/data/aggregates/hsb/" + currentYear + "/arc/raster/"
        raster = basedir + "/" + "hsb_" + currentYear + "_osgb"
    elif '2008' in currentYear:
        basedir = "E:/data/aggregates/hsb/" + currentYear + "/bathy/CD1/Processed Data/arc/raster/"
        raster = basedir + "/" + "hsb_" + currentYear + "_osgb"
    elif int(currentYear) > int(2008):
        basedir = "E:/data/aggregates/hsb/" + currentYear + "/bathy/CD1/Processed Data/arc/raster/"
        raster = basedir + "/" + "hsb_" + currentYear + "_osgb"
    else:
        basedir = "E:/data/aggregates/hsb/" 
        raster = basedir + currentYear + "/" + currentYear + "_c"

    outDir = "E:/data/arcmap_shapefiles/modelling/hsb/historic/sampled/"

    # Get the Spatial analyst licence
    arcpy.CheckOutExtension("Spatial")

    # Extract the values along the common profile polyline shapefile
    try:
        outExtractByMask1 = ExtractByMask(raster, polylineSample1)
    except:
        print "ExtractByMask failed (file probably already exists)."

    try:
        outExtractByMask2 = ExtractByMask(raster, polylineSample2)
    except:
        print "ExtractByMask failed (file probably already exists)."

    # Save the output
    try:
        outExtractByMask1.save(outDir + "/" + currentYear + "_1")
    except:
        print "ExtractByMask save failed (file probably already exists)."

    try:
        outExtractByMask2.save(outDir + "/" + currentYear + "_2")
    except:
        print "ExtractByMask save failed (file probably already exists)."

    # Convert those extracted rasters to ASCII rasters
    try:
        arcpy.RasterToASCII_conversion(outDir + "/" + currentYear + "_1", outDir + "/" + currentYear + "_1.asc")
    except:
        print "Conversion to ESRI ASCII raster failed (file probably already exists)."

    try:
        arcpy.RasterToASCII_conversion(outDir + "/" + currentYear + "_2", outDir + "/" + currentYear + "_2.asc")
    except:
        print "Conversion to ESRI ASCII raster failed (file probably already exists)."

    print "done."
