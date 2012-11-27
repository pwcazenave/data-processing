# Import system modules
import sys,string,os,arcgisscripting

# Create the Geoprocessor object
gp = arcgisscripting.create()

gp.Workspace = "E:/data/arcmap_shapefiles/culver/bathy/contours/4m/"

shpList = gp.ListFeatureClasses("*")
shp = shpList.Next()
while shp:
  if not gp.ListFields(shp,"Name").Next():
    print "Adding Year to " + shp + "..."
    gp.AddField_management(shp,"Year","TEXT","#","#","#","#","NON_NULLABLE","NON_REQUIRED","#")
    gp.DeleteField_management(shp,"Yeaer")
  shp = shpList.Next()
