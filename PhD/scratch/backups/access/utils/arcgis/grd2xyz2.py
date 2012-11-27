#!/usr/bin/env python
#------------------------------------------------------------------------
# grd2xyz2.py - This script converts an ESRI ascii grid into XYZ triplets
#              Values are centered in the cell.
#              Download Python free from www.python.org
#
#              Thanks to Leo Kreymborg for some pointers on speeding this
#              script up.
#
# David Finlayson
# June 14, 2004
# dfinlays@u.washington.edu
#
# 2005-10-26 - Removed dependency on Psyco (still optional)
#------------------------------------------------------------------------
import sys
from optparse import OptionParser

def commandline():
    """ Parse the command line and return the input and output file """

    # Load the option parser and get the commandline options
    parser = OptionParser(usage="usage: %prog [options] input.asc")
    parser.add_option("-f", "--file", dest="infile",
                      help="write x,y,z triplets to FILE", metavar="FILE")
    parser.add_option("-d", "--deliminator", dest="delim", metavar="DELIMINATOR",
                      help="seperate coordinates with DELIMINATOR")
    parser.add_option("-z", "--zonly", dest="zonly", action="store_true", default=False,
                      help="output only the z-values (no x or y coordinates)")
    (options, args) = parser.parse_args()

    # Did the user enter an ASCII grid filename?
    if len(args) != 1:
        parser.error("incorrect number of arguments")

    # Does the ASCII grid file exist?
    try:
        fin = open(args[0])
    except IOError:
        print
        print "Error opening ASCII grid: %s" % args[0]
        print "Double check the name of the file and be sure you have"
        print "read permision for this file."
        sys.exit(0)

    # Where do we send the output, to a file or stdout?
    if options.infile:
        try:
            fout = open(options.infile, 'w')
        except IOError, e:
            print "Cannot open the output file: %s" % args[0]
            print e
    else:
        fout = sys.stdout

    # What is the deliminator?
    if options.delim:
        delim = options.delim
    else:
        delim = "\t"

    # Do we output only z values?
    if options.zonly:
        zonly = True
    else:
        zonly = False

    return(fin, fout, delim, zonly)

def float2str(number):
    """ strips off trailing zeros from coordinates """
    s = "%f" % number
    if "." in s:
        s = s.rstrip("0").rstrip(".")
    return s

def main():
    """ main program logic """
    # Change the filenames here
    (fin, fout, delim, zonly) = commandline()

    # Process the file
    header = readheader(fin)
    if zonly == True:
        processfile_zonly(fin, fout, header)
    else:
        xstrings = xcoords(header)
        ystrings = ycoords(header)
        processfile_xyz(fin, fout, header, xstrings, ystrings, delim)

def processfile_xyz(fin, fout, header, xstrings, ystrings, delim):
    """ convert ascii grid to xyz """
    for row in range(header['nrow']):
        for col in range(header['ncol']):
            # Get new data if necessary
            if col == 0:
                line = fin.readline().split()

            # Write to output file
            outtxt = delim.join((xstrings[col], ystrings[row], line[col])) + '\n'
            fout.write(outtxt)

def processfile_zonly(fin, fout, header):
    """ convert ascii grid to z-only format """
    for row in range(header['nrow']):
        for col in range(header['ncol']):
            # Get new data if necessary
            if col == 0:
                line = fin.readline().split()

            # Write to output file
            fout.write(line[col] + '\n')

def readheader(fin):
    """ returns the 6 line header as a dict"""
    header = {}

    line = fin.readline().split()
    header['ncol'] = int(line[1])

    line = fin.readline().split()
    header['nrow'] = int(line[1])

    line = fin.readline().split()
    header['xllcorner'] = float(line[1])

    line = fin.readline().split()
    header['yllcorner'] = float(line[1])

    line = fin.readline().split()
    header['cellsize'] = float(line[1])

    line = fin.readline().split()
    header['NODATA_value'] = float(line[1])
    return(header)


def xcoords(header):
    """ calculates x coordinates of a grid"""
    x = []
    for col in range(header['ncol']):
        x.append(float2str(header['xllcorner'] + (0.5 * header['cellsize']) + (col * header['cellsize'])))
    return(x)

def ycoords(header):
    """ calculates y coordinates of a grid"""
    y = []
    for (j, row) in enumerate(range(header['nrow'])):
        y.append(float2str(header['yllcorner'] -
                           (0.5 * header['cellsize']) + (header['nrow'] - row) * header['cellsize']))
    return(y)

if __name__ == '__main__':
    try:
        # If psyco is installed this script runs much faster...
        import psyco
        psyco.profile()
    except ImportError:
        # Oh, well, it's not installed. We don't need it.
        pass
    main()
