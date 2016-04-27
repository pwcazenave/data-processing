#!/bin/bash

head -n24 RN-8550_1427467290824/bodc_series_metadata_summary.csv > bodc_series_metadata_summary.csv

for i in */bodc_series_metadata_summary.csv; do
    tail -q -n+25 $i >> bodc_series_metadata_summary.csv
done
