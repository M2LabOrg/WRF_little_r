'''
Functions for converting a time series to a little_r file.

File source: 
https://github.com/tommz9/python-little_r

Adapted here by: Michel Mesquita, Ph.D. (July 2021)
'''

from record import Record

def time_series_to_little_r(timestamps, data, station_id, lat, lon, height, variable, obs_filename, 
                            convert_to_kelvin=True):
    ''' Converts the time series (timestamps, data) of a variable to a little_r file.

    station_id, lat, lon are the weather station metadata.

    A new file is created for each time step. Note that "obs_filename" is the start of the file name.
    For instance, if we write "obs", the output file names will be:
    obs:<YYYY-MM-DD_HH>
    Or we could say "OUTPUT/obs", that is, we provide both the path to a folder called "OUTPUT" and
    the beginning of the file name. Note that the folder "OUTPUT" (or any other path) should 
    have been created beforehand.
    '''

    if len(timestamps) != len(data):
        raise ValueError('The timestamps and data do not have the same length')


    if convert_to_kelvin and variable == 'temperature':
        data = data + 273.15


    for timestamp, data_point in zip(timestamps, data):

        date_string = timestamp.strftime("%Y-%m-%d_%H")

        filename = '{}:{}'.format(obs_filename, date_string)

        with open(filename, 'w') as f:
                record = Record(station_id, lat, lon, height, timestamp)
                record[variable] = data_point

                f.write(record.little_r_report())
