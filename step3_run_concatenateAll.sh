#!/bin/bash

# This script concatenates the files in step2 and
# make them ready to be used in WRF 
# They are part of the input files needed for observation nudging.

# You should run this script after running step2_run_perl_RT_fdda_reformat_obsnud.py,
# which produces files with extension .obsnud, which you will concatenate

# You will also need to change the file name to OBS_DOMAIN101 for domain 1, 
#  and OBS_DOMAIN201 for domain 2, and so on, as described in the WRF Users' manual

# Syntax: bash step3_run_concatenateAll.sh

#Adapted here by: Michel Mesquita, Ph.D. (July 2021)
#

cat OUTPUT_STEP2/*.obsnud >> OUTPUT_STEP3/OBS_DOMAIN101