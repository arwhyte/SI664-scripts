import chardet
import logging
import os
import pandas as pd
import sys as sys


def main(argv=None):
	"""
	Utilize Pandas library to read meta_movie.csv file
	:param argv:
	:return:
	"""

	if argv is None:
		argv = sys.argv

	msg = [
		'Airlines source file encoding detected = {0}',
		'Airlines source file trimmed version written to file {0}',
		'Airports source file encoding detected = {0}',
		'Airports source file trimmed version written to file {0}',
		'Airport city, state, country locations written to file {0}',
		'Flights source file encoding detected = {0}',
		'Flights source file trimmed version written to file {0}',
		'Flights 4th Qtr 2015 trimmed version written to file {0}'
	]

	# Setting logging format and default level
	logging.basicConfig(format='%(levelname)s: %(message)s', level=logging.DEBUG)

	# Check source file encoding
	airlines_in = os.path.join('input', 'csv', 'flight_delays', 'airlines.csv')
	encoding = find_encoding(airlines_in)
	logging.info(msg[0].format(encoding))

	# Read in source with correct encoding and remove whitespace.
	airlines = read_csv(airlines_in, encoding, ',')
	airlines_trimmed = trim_columns(airlines)
	airlines_out = os.path.join('output', 'flight_delays', 'airlines-trimmed.csv')
	write_series_to_csv(airlines_trimmed, airlines_out, ',', False)
	logging.info(msg[1].format(os.path.abspath(airlines_out)))

	# Check source file encoding
	airports_in = os.path.join('input', 'csv', 'flight_delays', 'airports.csv')
	encoding = find_encoding(airports_in)
	logging.info(msg[2].format(encoding))

	# Read in source with correct encoding and remove whitespace.
	airports = read_csv(airports_in, encoding, ',')
	airports_trimmed = trim_columns(airports)
	airports_out = os.path.join('output', 'flight_delays', 'airports-trimmed.csv')
	write_series_to_csv(airports_trimmed, airports_out, ',', False)
	logging.info(msg[3].format(os.path.abspath(airports_out)))

	locations = extract_filtered_series(airports_trimmed,
		[
			'IATA_CODE',
			'CITY',
			'STATE',
			'COUNTRY'
		]
	)
	locations_out = os.path.join('output', 'flight_delays', 'airport_locations.csv')
	write_series_to_csv(locations, locations_out, ',', False)
	logging.info(msg[4].format(os.path.abspath(locations_out)))

	# Check source file encoding
	flights_in = os.path.join('input', 'csv', 'flight_delays', 'flights.csv')
	encoding = find_encoding(flights_in)
	logging.info(msg[5].format(encoding))

	# Read in source with correct encoding and remove whitespace.
	flights = read_csv(flights_in, encoding, ',')
	flights_trimmed = trim_columns(flights)
	flights_out = os.path.join('output', 'flight_delays', 'flights_2015-trimmed.csv')
	write_series_to_csv(flights_trimmed, flights_out, ',', False)
	logging.info(msg[6].format(os.path.abspath(flights_out)))

def extract_filtered_series(data_frame, column_list, drop_rule='all'):
	"""
	Returns a filtered Panda Series one-dimensional ndarray from a targeted column.
	Duplicate values and NaN or blank values are dropped from the result set which is
	returned sorted (ascending).
	:param data_frame: Pandas DataFrame
	:param column_list: list of columns
	:param drop_rule: dropna rule
	:return: Panda Series one-dimensional ndarray
	"""

	return data_frame[column_list].drop_duplicates().dropna(axis=0, how=drop_rule).sort_values(
		column_list)
	# return data_frame[column_list].str.strip().drop_duplicates().dropna().sort_values()


def find_encoding(fname):
	r_file = open(fname, 'rb').read()
	result = chardet.detect(r_file)
	charenc = result['encoding']
	return charenc


def read_csv(path, encoding, delimiter=','):
	"""
	Utilize Pandas to read in *.csv file.
	:param path: file path
	:param delimiter: field delimiter
	:return: Pandas DataFrame
	"""

	# UnicodeDecodeError: 'utf-8' codec can't decode byte 0x96 in position 450: invalid start byte
	# return pd.read_csv(path, sep=delimiter, encoding='utf-8', engine='python')

	return pd.read_csv(path, sep=delimiter, encoding=encoding, engine='python')
	# return pd.read_csv(path, sep=delimiter, engine='python')


def trim_columns(data_frame):
	"""
	:param data_frame:
	:return: trimmed data frame
	"""

	trim = lambda x: x.strip() if type(x) is str else x
	return data_frame.applymap(trim)


def write_series_to_csv(series, path, delimiter=',', row_name=True):
	"""
	Write Pandas DataFrame to a *.csv file.
	:param series: Pandas one dimensional ndarray
	:param path: file path
	:param delimiter: field delimiter
	:param row_name: include row name boolean
	"""

	series.to_csv(path, sep=delimiter, index=row_name)


if __name__ == '__main__':
	sys.exit(main())