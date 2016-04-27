"""
Parse the metadata files for each station and extract the useful bits into
a CSV file.

"""

import os
import csv
import glob

from HTMLParser import HTMLParser

class parser(HTMLParser):
    def __init__(HTMLParser):
        self.metadata = {}

    def handle_starttag(self, tag, attrs):
        print "Encountered a start tag:", tag
    def handle_endtag(self, tag):
        print "Encountered an end tag :", tag
    def handle_data(self, data):
        print "Encountered some data  :", data
        if data == 'Time Co-ordinates(UT)':
            print data

if __name__ == '__main__':

    files = glob.glob(os.path.join('metadata', '18844.html'))

    for file in files:
        # Slurp the file into a big string and pass that to the parser.
        with open(file, 'r') as f:
            meta = f.readlines()
        p = parser()
        p.feed(''.join(meta))
