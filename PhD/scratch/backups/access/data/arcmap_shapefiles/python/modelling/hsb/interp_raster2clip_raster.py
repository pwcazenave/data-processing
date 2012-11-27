import arcpy
import arcgisscripting

# Takes the results of the manually created NaturalNeighbour rasters
# and clips using the buffer shapefiles.

basedir = "E:/data/aggregates/hsb/"
years = ['1993','1994','1995','1996','1998','1999','2000','2001','2002','2003']
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

    # Get the raster extent
    rasterFile = arcgisscripting.Raster(savedRaster)
    rasterExtent = rasterFile.extent
    xmin = rasterExtent.XMin
    xmax = rasterExtent.XMax
    ymin = rasterExtent.YMin
    ymax = rasterExtent.YMax
    rasterMinMax = str(xmin)+" "+str(ymin)+" "+str(xmax)+" "+str(ymax)

    # Clip the interpolated raster with the buffer shapefile.
    arcpy.Clip_management(savedRaster,rasterMinMax,savedRaster+"_c",savedBuffer,"#","ClippingGeometry")

    print "done."
