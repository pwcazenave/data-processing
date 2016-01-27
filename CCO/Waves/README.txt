1. Put new files in raw_data.
2. Put new files' metadata in metadata.
3. cd into scripts and run get_locations.sh
4. cd up from script to the root and run scripts/combine_years.sh
5. Run python scripts/clean_data.py.

Note: locations.csv is created initially by get_locations.sh and then overwritten by clean_data.py (the latter omits sites with no valid temperature data).
