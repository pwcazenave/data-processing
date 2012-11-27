#Features2CSV.py
#
#Author Date
#  Dan Patterson
#  Dept of Geography and Environmental Studies
#  Carleton University, Ottawa, Canada
#  Dan_Patterson@carleton.ca
#
#Purpose
#  Convert a polyline or polygon layer to a unique point CSV file which
#  contains X, Y and available Z or M values.  You can optionally carry over
#  other field information to the file as well.  Multiparts are exploded
#  and the csv file can be added to your project using the Add XY Data menu
#  option.
#
#Properties (right-click on the tool and specify the following)
#General
#  Name   FeaturesToCSV
#  Label  Features to CSV
#  Desc   Produces a csv file which contains  X, Y and Z/M (if present)
#         along with optional attributes for all features in a feature
#         class.  Selections will be honored in the output if you desire
#         a subset.  An output projection can be specified as well, to
#         project any longitude/latitude output to another coordinate system.
#Source script ScriptNameHere.py
#
#Parameter list
#                                Parameter Properties
#           Display Name         Data type        Type      Direction  MultiValue
#  argv[1]  Input feature class  Feature Layer     Required  Input      No
#  argv[2]  Optional fields      Field             Optional  Input      Yes
#  argv[3]  Output text file     Text file         Required  Output     No
#  argv[4]  Output projection    Coordinate system Optional  Input      No
#--------------------------------------------------------------------
#Import the standard modules and the geoprocessor
import glob, os, sys, string, win32com.client  #common examples
gp = win32com.client.Dispatch("esriGeoprocessing.GpDispatch.1")
gp.AddToolbox("C:/Program Files/ArcGIS/ArcToolbox/Toolboxes/Data Management Tools.tbx")
#
#Get the input feature class, optional fields and the output filename
inFC = sys.argv[1]
desc=gp.Describe
theFields = gp.GetParameterAsText(1) #sys.argv[2]
outfile = sys.argv[3]
SpatialRef = sys.argv[4]
#
#check to see if it is a polyline or polygon file
gp.AddMessage("\n" + "FeaturesToCSV...begin processing...")
theType = desc(inFC).ShapeType
if theType == "Point":
  gp.AddMessage("Cannot process this class: " + theType + "\n")
  del gp
  sys.exit()
#
#check to see if a projection is needed
if SpatialRef != "#":
  #Create a temporary output file
  FullName = desc(inFC).CatalogPath
  thePath = (os.path.split(FullName)[0]).replace("\\","/")
  theFName = (os.path.split(FullName)[1]).replace(".shp","")
  gp.AddMessage("Path to input data:  " + thePath + "\n")
  #
  fc = thePath + "/" + theFName + "temp.shp"
  tempFile = thePath + "/" + theFName + "temp.shp"
  gp.AddMessage("Creating temporary file:  " + str(fc))
  try:
    gp.AddMessage("Projecting using:" + "\n" + str(SpatialRef))
    gp.Project_management(inFC,fc, SpatialRef)
   # gp.AddMessage("Out file : " + str(fc))
  except:
    gp.AddMessage("Unable to create output file")
    del outfile
    del gp
    sys.exit()
else:
  fc = inFC
  tempFile = ""
#
#Figure out which field is the geometry/shape field and
#  whether the file contains Z or M values
shapeField = desc(fc).ShapeFieldName
OIDField = desc(fc).OIDFieldName
isZ = desc(fc).hasZ
isM = desc(fc).hasZ
FieldList = string.split(theFields,";")
#
#Open a file for output and determine the appropriate file header.
csvFile = open(outfile,'w')
aHeader = "ID,PolyID,PartNum,PntNum,X,Y"
if isZ:
  aHeader=aHeader + ",Z"
elif isM:
  aHeader = aHeader + ",M"
if theFields <> "":
  aHeader = aHeader + "," + string.replace(theFields, ";", ",")
csvFile.writelines(aHeader)
#
#Get a read cursor on the feature class
#  Cycle through the shapes, which may be a single or multipart
#  and in the case of polygons, may contain donuts.
rows = gp.SearchCursor(fc)
row = rows.next()
aCount=0
while row:                       #cycle through the shapes
  aShape = row.Shape
  PntNum = 0
  i = 0
  while i < aShape.PartCount:    #cycle through the parts of the shape
    anArray = aShape.GetPart(i)
    numVertices = anArray.count  #number of vertices or null points
    anArray.Reset()
    pnt=anArray.Next()
    j = 0
    while j < (numVertices-1):   #cycle through the points of the shape
      pnt = anArray.GetObject(j)
      PntID = str(aCount) + ","
      PolyID = str(row.GetValue(OIDField)) + ","
      aPart = str(i) + ","
      aNum = str(PntNum) + ","
      X = str(pnt.X) + ","
      Y = str(pnt.y)
      #
      if isZ:
        Z = "," + str(pnt.Z)
      else:
        Z = ""
      if isM:
        M = "," + str(pnt.M)
      else:
        M = ""
      #
      otherData=""
      if theFields <> "":
        for k in FieldList:
          otherData = otherData + "," + str(row.GetValue(k))
      #
      #check the next point to see if it associated with rings/donuts for polygons
      pnt = anArray.GetObject(j + 1)
      if not pnt:                 #null point identifying donut
        j = j + 1
      else:
        aLine = "\n" + PntID + PolyID +  aPart + aNum + X + Y + Z + M + otherData
        #
        #gp.AddMessage(aLine)  #uncomment if you want to see the output
        #
        PntNum = PntNum + 1
        aCount = aCount + 1
        csvFile.writelines(aLine) 
      j = j + 1
    i = i + 1
  row = rows.next()               # Get the next feature and repeat
#
#Close the file and delete the temporary files
#  and other objects using the glob module.
csvFile.flush()
csvFile.close()
del rows
del fc
#
delString = string.replace(str(tempFile),"shp","*")
deleteList = glob.glob(delString)
for i in deleteList:
  gp.AddMessage("Deleting temporary file:  " + str(i))
  os.remove(i)
#
del gp