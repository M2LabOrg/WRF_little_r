#!/usr/bin/env python

"""
This script creates WRF ready files using the little_r formatted files. 
They are part of the input files needed for observation nudging.

Note that: 
- You need to step1_run_time_series_converter.py first

- Here we convert to the format needed by WRF
- You do that by running: 

$ perl RT_fdda_reformat_obsnud.pl OUTPUT/obs:2021-04-14_02
$ perl RT_fdda_reformat_obsnud.pl OUTPUT/obs:2021-04-14_03
$ (and so on)

- This will produce files with extension .obsnud, which you will concatenate
  (see example below)

- You will also need to change the file name to OBS_DOMAIN101 for domain 1, 
  and OBS_DOMAIN201 for domain 2, and so on, as described in the WRF Users' manual

$ cat *.obsnud >> OBS_DOMAIN101

Adapted here by: Michel Mesquita, Ph.D. (July 2021)
"""

import os
import glob

for filepath in glob.iglob('OUTPUT_STEP1/*'):
    print(filepath)
    filename = os.path.basename(filepath)
    os.system(f"perl RT_fdda_reformat_obsnud.pl {filepath}")
    os.system("mv OUTPUT_STEP1/*.obsnud OUTPUT_STEP2/")
    os.system("rm OUTPUT_STEP1/*.tmp")

