# Author: Rajinder Nagi, Esri, Redlands
# Date: 28 Dec, 2010

import arcpy
import sys 
import os

SoilsMerged = r"C:\Users\goosin\Desktop\JIBS\jibs_area_test.shp"    ## Provide name and path of the merged feature class


soilsList = []

if __name__ == "__main__":
    try:
        SrcPath = r"C:\Users\goosin\Desktop\JIBS"  ## Provide the path for data with subfolder here
        for root, dirs, files in os.walk(SrcPath, topdown=True):
            print root, dirs, files
            for filename in files:
                print filename

                # check if 'polygon' name exists in shapefile name
                if filename.find("polygon") == 0:
                        print os.path.join(root, filename)
                        soils = str(os.path.join(root, filename))
                        soilsList.append(soils)
                    
        arcpy.Merge_management(soilsList, SoilsMerged)
                                    
    except Exception, ErrorDesc:
        #If an error set output boolean parameter "Error" to True.
        arcpy.AddError(str(ErrorDesc))    
        row = None
        rows = None
