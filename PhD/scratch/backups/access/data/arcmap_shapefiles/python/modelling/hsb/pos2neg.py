import arcpy
import arcgisscripting

# Makes negative depths positive and create a hillshade for the
# negative raster.

basedir = "E:/data/aggregates/hsb/"
years = ['1993','1994','1995','1996','1998','1999','2000','2001','2002','2003']

for csv in years:
    print "Working on " + csv + "...",

    raster = basedir + csv + "/" + csv + "_c"

    arcpy.CheckOutExtension("Spatial")

    #arcpy.Times_3d(raster, "-1", raster + "_pos")

    arcpy.HillShade_3d(raster + "_pos", raster + "_pos_hs", "60", "45", "NO_SHADOWS", "1")

    print "done."
