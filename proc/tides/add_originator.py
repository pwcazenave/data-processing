import sqlite3
import csv

noisy = False

con = sqlite3.connect('./tides.db')
c = con.cursor()

metaDataFiles = ('/users/modellers/pica/Work/data/NSTD/shelf_stations_latlong_sql.csv',\
                 '/users/modellers/pica/Work/data/NTSLF/shelf_stations_sql.csv',\
                 '/users/modellers/pica/Work/data/NTSLF/BPR/shelf_stations_sql.csv',\
                 '/users/modellers/pica/Work/data/SHOM/shelf_stations_sql_edited.csv')

# Add two new fields to the Stations tables in the database
try:
    # New fields have to be added one at a time
    c.execute('ALTER TABLE Stations ADD COLUMN originatorName TEXT COLLATE nocase')
    c.execute('ALTER TABLE Stations ADD COLUMN originatorLongName TEXT COLLATE nocase')
except:
    print 'Tables already exist'


for file in metaDataFiles:
    # Get the data originator from the directory name (e.g. PSMSL etc).
    if 'NSTD' in file:
        originator = 'NSTD'
        originatorLong = 'North Sea Tidal Data'
    elif 'NTSLF' in file and 'BPR' not in file:
        originator = 'NTSLF'
        originatorLong = 'National Tide and Sea Level Facility'
    elif 'NTSLF/BPR' in file:
        originator = 'NTSLF-BPR'
        originatorLong = 'Historical Bottom Pressure Sensor Recorder'
    elif 'SHOM' in file:
        originator = 'SHOM'
        originatorLong = 'Service Hydrographique et Oceanographique de la Marine'
    else:
        print 'Unknown originator. Skipping.'
        break

    # Now we need to go through each metadata file and alter the relevant
    # record in Stations.
    fileHandle = csv.reader(open(file, 'r'))
    for row in fileHandle:
        c.execute('UPDATE stations set originatorName=?, originatorLongName=? where shortName is ?', [originator, originatorLong, row[2]])
        if noisy:
            ttt = c.execute('SELECT * FROM Stations WHERE shortName is ?', [row[2]])
            for i in ttt.fetchall():
                print i

# Commit the changes to the database
con.commit()
con.close()
