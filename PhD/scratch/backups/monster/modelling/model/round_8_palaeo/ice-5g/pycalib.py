#!/usr/bin/env python
""" 
pycalib - Creates a set of DHI MIKE21 model files. 

Based on a template file, replaces the requisite lines in that template
with the values supplied on the command line. These include, at a 
minimum:

    -b|--boundary   - the boundary type (bte0y, MIKE etc.)
    -d|--date       - the model start date (YYYY-MM-DD)
    -g|--grid       - the model mesh.
    -m|--mannings   - the Manning's number(s) or file name for variable.
    -n|--name       - the calibration round name
    -o|--output     - the output file types (SHOM, NTSLF, NHS etc.)

The supplied argument to -m or --mannings must be of the following format:
    40          - single value
    40,50,60    - list of values
    40-60:5     - start, end and increment (inclusive)
    filename    - specify dfsu file name for variable Manning's number. 
                  Both the bathymetry mesh and the Manning's dfsu file 
                  must both reside in the same directory.

Example:

    pycalib \
        -b bte0y \
        -d 2003-01-28 \
        -g gebco_00ka_v9.mesh \
        -m filename.dfsu,20,30,40 \
        -n rms_calibration
        -o NTSLF-SHOM-NHS

Pierre Cazenave (pwc101@soton.ac.uk)

"""

"""
ChangeLog:

v1.0    - 2011-01-28
v1.0.1  - 2011-01-31    - Added variable Manning's roughness support.
v1..02  - 2011-02-01    - Improved variable Manning's grid support with
                        extra option for specifying Manning's grid with -g.

TODO: Make work independent of a template file, or at least capable of
    altering any aspect of the template irrespective of its line number.

"""

import os
import sys
import getopt

def parseMannings(argument):
    """ Parses the Manning's number argument for a list, range, single value or dfsu file. """

    if "," in argument:
        # List of values
        mannings = argument.split(",")
    elif "-" in argument or ":" in argument:
        # List of range of values
        if ":" not in argument or "-" not in argument:
            print __doc__
            assert False, "Incorrectly formatted range argument."
        else:
            mRange, mInc = argument.split(":")
            if len(mRange.split("-")) is not 2:
                # Looks like the format of the range has the : and - in the wrong places...
                print __doc__
                assert False, "Incorrect range parameters. Check the start, end and increment value formatting."
            else:
                mMin = int(mRange.split("-")[0])
                mMax = int(mRange.split("-")[1])
                if mMax < mMin or mMax-mMin < int(mInc):
                    print __doc__
                    if mMax < mMin:
                        assert False, "Incorrect range parameters. The maximum is less than the minimum."
                    else:
                        assert False, "Incorrect range parameters. The minimum is greater than the maximum."
                else:
                    # HACK ALERT.
                    # Force range to include mMax value by incrementing by one.
                    mannings = range(mMin,mMax+1,int(mInc))
    else:
        # Must be a single value. Force value to be a list.
        mannings = [argument]

    return mannings
    

def parseArgs(arguments):
    """ Parses the inputs to check they're valid."""

    try:
        opts, args = getopt.gnu_getopt(arguments[1:], "b:d:g:hm:n:o:t:", ["boundary=", "date=", "grid=", "help", "mannings=", "name=", "output=", "template="])
    except getopt.GetoptError, err:
        print __doc__
        print str(err)
        sys.exit(2)

    # Check there are enough input arguments
    if len(opts) < 6:
        print __doc__
        assert False, "Not enough input arguments."
        sys.exit(1)

    for o, a in opts:
        if o in ("-b", "--boundary"):
            boundary = a
        elif o in ("-d", "--date"):
            if "-" not in a:
                print __doc__
                assert False, "Incorrectly formatted date. Must be YYYY-MM-DD."
            else:
                date = a
        elif o in ("-g", "--grid"):
            grid = a
        elif o in ("-h", "--help"):
            print __doc__
            sys.exit(0)
        elif o in ("-m", "--mannings"):
            mannings = parseMannings(a)
        elif o in ("-n", "--name"):
            name = a
        elif o in ("-o", "--output"):
            output = a
        elif o in ("-t", "--template"):
            template = a
        else:
            print __doc__
            assert False, "Unknown option"

    return boundary, date, grid, mannings, name, output, template

def readTemplateWriteModel(template, boundary, date, grid, mannings, name, output):
    """
    Reads the template file in and outputs a new file into the appropriate 
    directory with the new information included. Bear in mind this works on line
    numbers for the time being, so it's likely to be quite fragile.
    TODO: Make this work with any input file by correctly parsing the file and 
    inserting the new values irrespective of the line number at which the parameter
    is found.
    
    """
    
    # Two directory prefixes (E:\ and H:\)
    ePref = 'E:\\modelling'
    hPref = 'H:\\modelling'
    # The modelling round
    modelRound = 'round_8_palaeo'

    # Output file name constructed from the various inputs (grid, boundary, date 
    # etc.)
    file = open(template,'r')
    base, ext = os.path.splitext(template)

    # Make the output directories, file names, result names etc. If we've got a 
    # dfsu Manning's file, dump everything in Mvar. This makes the MATLAB 
    # processing much easier.
    if os.path.isfile(ePref+'\\data\\bathymetry\\meshes\\'+modelRound+'\\'+'ice-5g\\'+name+'\\dfsu\\'+mannings):
    	outDir = hPref+'\\model\\'+modelRound+'\\ice-5g\\'+name+"\\Mvar\\"
        resDir = hPref+'\\results\\'+modelRound+'\\ice-5g\\'+name+"\\Mvar\\"
        outName = outDir+boundary+"_"+os.path.splitext(grid)[0]+"_M"+str(os.path.splitext(mannings)[0])+"_"+date+"_"+output+ext
        resName = boundary+"_"+os.path.splitext(grid)[0]+"_M"+str(os.path.splitext(mannings)[0])+"_"+date+"_"+output
    else:
    	outDir = hPref+'\\model\\'+modelRound+'\\ice-5g\\'+name+"\\M"+str(mannings)+"\\"
        resDir = hPref+'\\results\\'+modelRound+'\\ice-5g\\'+name+"\\M"+str(mannings)+"\\"
        outName = outDir+boundary+"_"+os.path.splitext(grid)[0]+"_M"+str(mannings)+"_"+date+"_"+output+ext
        resName = boundary+"_"+os.path.splitext(grid)[0]+"_M"+str(mannings)+"_"+date+"_"+output

    # Check to see if we have output directories, and make them where 
    # necessary.
    try:
        os.makedirs(outDir)
    except OSError, error:
        if os.path.isdir(outDir):
            # Already there so we can continue
            pass
        elif os.path.isfile(outDir):
            # Directory was a file
            print "Output directory exists as a file."
            sys.exit(4)
        else:
            # Some other error
            raise error

    try:
        os.makedirs(resDir)
    except OSError, error:
        if os.path.isdir(resDir):
            # Already there so we can continue
            pass
        elif os.path.isfile(resDir):
            # Directory was a file
            print "Output directory exists as a file."
            sys.exit(4)
        else:
            # Some other error
            raise error

    outFile = open(outName, 'w')

    for linenum, line in enumerate(file):

        if linenum+1 == 11:
            # Model input mesh
            line = '      file_name = |'+ePref+'\\data\\bathymetry\\meshes\\'+modelRound+'\\'+'ice-5g\\'+name+'\\mesh\\'+grid+'|\n'
            outFile.write(line)
        elif linenum+1 == 67:
            # Model start time
            line = '      start_time = '+date.split("-")[0]+', '+date.split("-")[1]+', '+date.split("-")[2]+', 0, 0, 0\n'
            outFile.write(line)

        elif linenum+1 == 286:
            # Manning's number roughness section
            if os.path.isfile(ePref+'\\data\\bathymetry\\meshes\\'+modelRound+'\\'+'ice-5g\\'+name+'\\dfsu\\'+mannings):
                # Variable Manning's with mesh. Set the line to "format = 2" for filename
                line = '            format = 2\n'
                outFile.write(line)
            else:
                # Use existing line because Manning's is not a mesh (format = 0
                # as in the template).
                outFile.write(line)
        elif linenum+1 == 287:
            # Check for variable Manning's by finding is mannings is a file
            if os.path.isfile(ePref+'\\data\\bathymetry\\meshes\\'+modelRound+'\\'+'ice-5g\\'+name+'\\dfsu\\'+mannings):
                # Variable Manning's with mesh, so output line as is
                outFile.write(line)
            else:
                # Constant Manning's, so use supplied value.
                line = '            constant_value = '+str(mannings)+'\n'
                outFile.write(line)
        elif linenum+1 == 288:
            if os.path.isfile(ePref+'\\data\\bathymetry\\meshes\\'+modelRound+'\\'+'ice-5g\\'+name+'\\dfsu\\'+mannings):
                line = '            file_name = |'+ePref+'\\data\\bathymetry\\meshes\\'+modelRound+'\\'+'ice-5g\\'+name+'\\dfsu\\'+mannings+'|\n'
                outFile.write(line)
            else:
                # Constant Manning's number roughness
                outFile.write(line)
                outFile.write(line)
        elif linenum+1 == 672:
            # First boundary (south)
            if boundary == 'mike':
                line = '            file_name = |'+ePref+'\\data\\boundary_files\\'+modelRound+'\\modern\\dfs1\\mike_uehara_gshhs_peltier_00ka_v7_south.dfs1|\n'
                outFile.write(line)
            elif boundary == 'bte0y':
                line = '            file_name = |'+ePref+'\\data\\boundary_files\\'+modelRound+'\\uehara_boundary\\ice-5g\\dfs1\\'+boundary+'-000ka_south.dfs1|\n'
                outFile.write(line)
            else:
                print __doc__
                assert False, "Unknown boundary type. Check the name and try again."
        elif linenum+1 == 697:
            # First boundary (north)
            if boundary == 'mike':
                line = '            file_name = |'+ePref+'\\data\\boundary_files\\'+modelRound+'\\modern\\dfs1\\mike_uehara_gshhs_peltier_00ka_v7_north.dfs1|\n'
                outFile.write(line)
            elif boundary == 'bte0y':
                line = '            file_name = |'+ePref+'\\data\\boundary_files\\'+modelRound+'\\uehara_boundary\\ice-5g\\dfs1\\'+boundary+'-000ka_north.dfs1|\n'
                outFile.write(line)
            else:
                print __doc__
                assert False, "Unknown boundary type. Check the name and try again."
        elif linenum+1 == 722:
            # First boundary (west)
            if boundary == 'mike':
                line = '            file_name = |'+ePref+'\\data\\boundary_files\\'+modelRound+'\\modern\\dfs1\\mike_uehara_gshhs_peltier_00ka_v7_west.dfs1|\n'
                outFile.write(line)
            elif boundary == 'bte0y':
                line = '            file_name = |'+ePref+'\\data\\boundary_files\\'+modelRound+'\\uehara_boundary\\ice-5g\\dfs1\\'+boundary+'-000ka_west.dfs1|\n'
                outFile.write(line)
            else:
                print __doc__
                assert False, "Unknown boundary type. Check the name and try again."
        elif linenum+1 == 747:
            # First boundary (east)
            if boundary == 'mike':
                line = '            file_name = |'+ePref+'\\data\\boundary_files\\'+modelRound+'\\modern\\dfs1\\mike_uehara_gshhs_peltier_00ka_v7_east.dfs1|\n'
                outFile.write(line)
            elif boundary == 'bte0y':
                line = '            file_name = |'+ePref+'\\data\\boundary_files\\'+modelRound+'\\uehara_boundary\\ice-5g\\dfs1\\'+boundary+'-000ka_east.dfs1|\n'
                outFile.write(line)
            else:
                print __doc__
                assert False, "Unknown boundary type. Check the name and try again."
        elif linenum+1 == 1528:
            # Area output (dsfu)
            line = '            file_name = |'+resDir+resName+'_area.dfsu|\n'
            outFile.write(line)
        elif linenum+1 == 1641:
            # Point output (dfs0)
            line = '            file_name = |'+resDir+resName+'_tides.dfs0|\n'
            outFile.write(line)
        else:
            # Since we haven't line.stripped() this, it's still got its newline 
            # character, so we'll not output with a newline here.
            outFile.write(line)

    # Clean up after ourselves.
    file.close()
    outFile.close()

  
def main():

    boundary, date, grid, mannings, name, output, template = parseArgs(sys.argv)

    for M in mannings:
        readTemplateWriteModel(template, boundary, date, grid, M, name, output)



if __name__ == "__main__":
    sys.exit(main())
