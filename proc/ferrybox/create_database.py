"""
Take the FerryBox data and add it to a simple SQLite database.

This one's slow because I iterate through each file and then each row in the
file. There's probably a way to use a numpy array to do this better, but I just
needed it done, so this will have to do.

"""

import sqlite3
import csv
import sys
import os
import re
import glob

import numpy as np


if __name__ == '__main__':

    noisy = True

    con = sqlite3.connect('./ferrybox.db')
    cur = con.cursor()

    base = '/users/modellers/pica/Data/FerryBox/'

    # Get a list of unique field names for the data by reading the header of
    # each raw data file.
    fields = []
    for fname in glob.glob(os.path.join(base, 'raw_data', '*.csv')):
        f = open(fname, 'rt')
        reader = csv.DictReader(f)
        # Append the new keys to the list of existing keys
        for k in reader.fieldnames:
            k = k.strip()
            if k not in fields and k:
                fields.append(k)

    # Create a new database and add the metadata to a field called Stations with
    # some of the metadata fields.
    try:
        with con:
            # Create a table with all the possible measured field names in
            # fields. Some will be blank if the field is missinge in the raw
            # data. Build the SQLite3 string up incrementally.
            query = 'CREATE TABLE PrideOfBilbao('
            for c, ff in enumerate(fields):
                if ff == 'o_time' or ff == 'o_mon' or ff == 'o_day' or ff == 'hh' or ff == 'mm' or ff == 'ss' or ff == 'ddd' or ff == 'yy' or ff == 'fbox2_id' or ff == 'o_hh'or ff == 'o_mm' or ff == 'o_ss' or ff == 'o_dd' or ff == 'o_mo':
                    query = query + '{} INT'.format(ff)
                elif ff == 'add_dat' or ff == 'o_time':
                    query = query + '{} TEXT COLLATE nocase'.format(ff)
                else:
                    query = query + '{} FLOAT(10)'.format(ff)

                if c != len(fields) - 1:
                    query = query + ', '

            query = query + ')'

            cur.execute(query)

            # Iterate through all the files we have and read the data in as
            # above (to find the list of unique fields).
            for fname in glob.glob(os.path.join(base, 'raw_data', '*.csv')):
                f = open(fname, 'rt')
                reader = csv.DictReader(f)
                idx = [c for c, i in enumerate(fields) if i in reader.fieldnames]
                for row in reader:
                    keys = reader.fieldnames
                    data = []
                    _ = [data.append(row[k]) for k in keys]
                    cur.execute('INSERT INTO PrideOfBilbao ({}) VALUES (\'{}\')'.format(', '.join(keys), '\', \''.join(data)))
                    #for key in row:
                    #    if key:
                    #        try:
                    #            cur.execute('INSERT INTO {} ({}) VALUES (\'{}\')'.format('PrideOfBilbao', key, row[key]))
                    #        except e:
                    #            print e.message
                    #            raise Exception('Error inserting values into table {} from file {}'.format(key, fname))


    except sqlite3.Error, e:
        if con:

            #con.rollback()

            print 'Error: {}'.format(e.message)
            sys.exit(1)

    finally:
        if con:
            con.commit()
            con.close()
        f.close()
