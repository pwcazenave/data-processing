#!/bin/bash

# Script to split the header from the data

# Headers
for i in *.lst; do sed '/\ \ \ \ \ \ \ 1)/,$d' $i > ./headers/$(basename $i); done

# Data
for i in *.lst; do sed '1,/^Number/d' $i > ./formatted/$(basename $i); done
