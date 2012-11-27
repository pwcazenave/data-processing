#------------------------------------------------------------------------
# grd2xyz.py - This script converts an ESRI ascii grid into XYZ triplets
#              Values are centered in the cell.
#              Download Python free from www.python.org
#
#              Thanks to Leo Kreymborg for some pointers on speeding this
#              script up.
#
# David Finlayson
# February 3, 2004
# dfinlays@u.washington.edu
#------------------------------------------------------------------------

# Directions: Edit the filenames below, save the script in the directory
# with your ascii grid, and run (double-click) this script.

# --------------------- Make your changes here --------------------------

infile = "pugetgrid.asc"               # ESRI ASCII Grid filename
outfile = "output.xyz"             # output filename for x,y,z triplets

# --------------------- Below here, leave alone -------------------------
def float2str(number):
    """ strips off trailing zeros from coordinates """
    s = "%f" % number
    if "." in s:
        s = s.rstrip("0").rstrip(".")
    return s

# Load the grid files
fin = open(infile, 'r')
fout = open(outfile, 'w')

# Read the header     
line = fin.readline().split()
ncol = int(line[1])

line = fin.readline().split()
nrow = int(line[1])

line = fin.readline().split()
xllcorner = float(line[1])

line = fin.readline().split()
yllcorner = float(line[1])

line = fin.readline().split()
cellsize = float(line[1])

line = fin.readline().split()
NODATA_value = float(line[1])

# Pre-calculate the x and y coordinates

xcoords = []
for col in range(ncol):
    xcoords.append(float2str(xllcorner + (0.5 * cellsize) + (col * cellsize)))

ycoords = []
for row in range(nrow):
    ycoords.append(float2str(yllcorner - (0.5 * cellsize) + (nrow - row) * cellsize))

# Process the file
print "Converting %s to X,Y,Z triplets...\n" % (infile)
for row in range(nrow):
    if (row % 100) == 0: print ".",
    for col in range(ncol):
        # Get new data if necessary
        if col == 0: line = fin.readline().split()
        fout.write("%s,%s,%s\n" % (xcoords[col], ycoords[row], line[col]))
        
# Exit
fin.close()
fout.close()

print "\nConversion complete.\n"
raw_input("Press ENTER to exit.\n")
