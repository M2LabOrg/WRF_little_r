#!/usr/bin/env python

"""
This script creates little_r formatted files to be used
in WRF. They are part of the input files needed for observation nudging.

The script makes use of the function time_series_to_little_r, which is a 
FORTRAN wrapper found in time_series_converter.py and record.py

Wrapper sources: 
https://github.com/tommz9/python-little_r
https://github.com/valcap/csv2little_r

Note that: 
- You need to install the Python packages needed to run this script:

$ pip install -r requirements.txt 

- After running this script, you need to convert it to the format needed by WRF
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

import pandas as pd
from pandas.tseries.offsets import DateOffset
from time_series_converter import time_series_to_little_r

df = pd.read_csv('inputToyData.csv', sep=";")
df.set_index(pd.to_datetime(df['datetime']), drop = False, inplace = True)
df.index = df.index.tz_localize('GMT').tz_convert('Europe/Oslo') 


time_series_to_little_r(
            df.index, 
            df['temperature'],
            'Bergen', # location
            60.3971, # latitude
            5.3244, # longitude
            40, # altitude
            'temperature', # variable
            'OUTPUT_STEP1/obs', # start of filename or path + start of filename
            convert_to_kelvin=True) 

