import arcpy
import arcgisscripting

basedir = "E:/data/aggregates/hsb/"
years = ['1993','1994','1995','1996','1998','1999','2000','2001','2002','2003']
#spRef = "PROJCS['British_National_Grid',GEOGCS['GCS_OSGB_1936',DATUM['D_OSGB_1936',SPHEROID['Airy_1830',6377563.396,299.3249646]],PRIMEM['Greenwich',0.0],UNIT['Degree',0.0174532925199433]],PROJECTION['Transverse_Mercator'],PARAMETER['False_Easting',400000.0],PARAMETER['False_Northing',-100000.0],PARAMETER['Central_Meridian',-2.0],PARAMETER['Scale_Factor',0.9996012717],PARAMETER['Latitude_Of_Origin',49.0],UNIT['Meter',1.0]];-5220400 -15524400 10000;-100000 10000;-100000 10000;0.001;0.001;0.001;IsHighPrecision"
spRef = arcpy.SpatialReference('C:\Program Files (x86)\ArcGIS\Desktop10.0\Coordinate Systems\Projected Coordinate Systems\National Grids\Europe\British National Grid.prj')

for csv in years:
    print "Working on " + csv + "...",
    if '2004' in csv:
        inTable = basedir+csv+"/bathy/raw_data/"+csv+".csv"
    else:
        inTable = basedir+csv+"/"+csv+".csv"

    x_coords = 'eastings'
    y_coords = 'northings'
    z_coords = 'depth'
    outLayer = csv
    savedLayer = basedir+csv+"/"+outLayer+".lyr"
    savedShapefile = basedir+csv+"/"+outLayer+".shp"
    savedBuffer = basedir+csv+"/"+outLayer+"_buffer.shp"
    savedRaster = basedir+csv+"/"+outLayer
    rasterSize = '25'

    # Get the Spatial analyst licence
    arcpy.CheckOutExtension("Spatial")
    
    arcpy.MakeXYEventLayer_management(inTable, x_coords, y_coords, outLayer, spRef, z_coords)
    
    arcpy.SaveToLayerFile_management(outLayer, savedLayer)

    # Convert layer to shapefile
    arcpy.CopyFeatures_management(savedLayer, savedShapefile, "#", "0", "0", "0")

    # Do buffer analysis on the shapefile with 120m radius with a full merge of buffers.
    arcpy.Buffer_analysis(savedShapefile,savedBuffer,"120 Meters","FULL","ROUND","ALL","#")

    # NearNeighbour interpolate the point bathymetry
    arcpy.NaturalNeighbor_3d(savedLayer,z_coords,savedRaster,rasterSize)


    print "done."
