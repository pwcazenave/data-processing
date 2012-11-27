#!/bin/bash

while read line; do
   awk -F"," '{
      printf \
      "\t\t<TimeStamp value=\"%s %s\">\n" \
      "\t\t\t<Latency value=\"0.000000\"/>\n" \
      "\t\t\t<SensorClass value=\"Swath\"/>\n" \
      "\t\t\t<TransducerEntries>\n" \
      "\t\t\t\t<Transducer Number=\"1\" StartBeam=\"1\" Model=\"%s\">\n" \
      "\t\t\t\t\t<Manufacturer value=\"%s\"/>\n" \
      "\t\t\t\t\t<Offsets X=\"%s\" Y=\"%s\" Z=\"%s\" Latency=\"%s\"/>\n" \
      "\t\t\t\t\t<MountAngle Pitch=\"%s\" Roll=\"%s\" Azimuth=\"%s\"/>\n" \
      "\t\t\t\t</Transducer>\n" \
      "\t\t\t</TransducerEntries>\n" \
      "\t\t\t<Comment value=\"%s\"/>\n" \
      "\t\t</TimeStamp>\n", \
      $1,$2,$11,$10,$4,$5,$6,$3,$7,$8,$9,$13}'
done < ./hastings_2005_bathy_line_info.csv \
   > new_sections.txt

exit 0
