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
		'Flights trimmed file encoding detected = {0}',
		'Flights trimmed file read {0}',
		'Aircraft tail numbers written to file {0}'
	]

	# Setting logging format and default level
	logging.basicConfig(format='%(levelname)s: %(message)s', level=logging.DEBUG)

	# Read in trimmed version of the orignal flights csv
	flights_in = os.path.join('output', 'flight_delays', 'flights_20151125_to_27-trimmed.csv')
	encoding = find_encoding(flights_in)
	logging.info(msg[0].format(encoding))

	# Read in source with correct encoding and remove whitespace.
	flights = read_csv(flights_in, encoding, ',')
	logging.info(msg[1])

	# aircraft table
	aircraft = extract_filtered_series(flights, ['TAIL_NUMBER'])
	aircraft_out = os.path.join('output', 'flight_delays', 'aircraft.csv')
	write_series_to_csv(aircraft, aircraft_out, ',', False)
	logging.info(msg[2].format(os.path.abspath(aircraft_out)))


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