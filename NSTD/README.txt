Order to run scripts to get from raw data to metadata to processed files

1. get_locations.sh
2. convert_coordinates.sh

After that, you need to rename the DDH stations to DDH_1 etc. in the
shelf_stations_latlong.csv and save that as a new file called
shelf_stations_latlong_edited.csv. Once you have that file, strip its header
to make shelf_stations_latlong_edited_sql.csv.

To make a metadata file for the import in the SQL database, use the following
command:

sort -uk1,2 -t, shelf_stations_latlong_edited_sql.csv | awk -F, '{OFS=","; print
$1,$2,$4,$4}' > shelf_stations_latlong_sql.csv

That strips out the duplicates leaving only the locations with their short and
long names (in this case both the same thing). That file can then be used with
the add_data_sql_multi-table.sh script to populate the SQL database. It is
also used by plot_tides.py to plot model results against observations.
