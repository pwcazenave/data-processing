#!/bin/bash

# Remove the BODC headers from the data

parallel sed '0,/^Number/d' "{}" \> formatted/"{/}" ::: raw_data/*.lst
