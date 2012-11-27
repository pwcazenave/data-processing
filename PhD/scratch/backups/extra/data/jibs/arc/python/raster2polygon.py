# RasterToPolygon_sample.py
# Description: 
#   Converts a raster to polygon features.
# Requirements: None
# Author: ESRI
# Date: Oct 20, 2005
# Import system modules
import arcgisscripting

# Create the Geoprocessor object
gp = arcgisscripting.create()

try:
    # Set local variables
    InRaster = 'C:\Users\goosin\Desktop\JIBS\jibs_50m'
    OutPolygonFeatures = "C:\Users\goosin\Desktop\JIBS\raster2polygon.shp"

    # Process: RasterToPolygon_conversion
    gp.RasterToPolygon_conversion(InRaster, OutPolygonFeatures, "NO_SIMPLIFY")

except:
    # Print error message if an error occurs
    print gp.GetMessages()
