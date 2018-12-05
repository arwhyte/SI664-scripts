import chardet
import logging
import os
import pandas as pd
import sys as sys


def main(argv=None):
	"""
	Utilize Pandas library to read in both UNSD M49 country and area .csv file
	(tab delimited) as well as the UNESCO heritage site .csv file (tab delimited).
	Extract regions, sub-regions, intermediate regions, country and areas, and
	other column data.  Filter out duplicate values and NaN values and sort the
	series in alphabetical order. Write out each series to a .csv file for inspection.
	"""
	if argv is None:
		argv = sys.argv

	msg = [
		'Source file encoding = {0}',
		'Source file read and trimmed version written to file {0}',
		'Artwork types written to file {0}',
		'Object data written to file {0}',
		'Artists written to file {0}',
		'Artist nationalities written to file {0}',
		'Artist prefixes written to file {0}',
		'Artist roles written to file {0}',
		'Cities written to file {0}',
		'Classifications written to file {0}',
		'Countries written to file {0}',
		'Departments written to file {0}',
		'Medium written to file {0}',
		'In Public Domain written to file {0}',
		'Regions written to file {0}',
		'Repositories written to file {0}',
	]

	# Setting logging format and default level
	logging.basicConfig(format='%(levelname)s: %(message)s', level=logging.DEBUG)

	# Check source file encoding
	source_path = os.path.join('input', 'csv', 'met_data_seroka-orig.csv')
	encoding = find_encoding(source_path)
	logging.info(msg[0].format(encoding))

	# Read in source with correct encoding and remove whitespace.
	source_data_frame = read_csv(source_path, encoding, '\t')
	source_data_frame_trimmed = trim_columns(source_data_frame)

	# Turned off as trimmed source file now includes manual fixes
	# source_trimmed_csv = os.path.join('output', 'met_artwork', 'met_artwork-trimmed.csv')
	# write_series_to_csv(source_data_frame_trimmed, source_trimmed_csv, '\t', False)
	# logging.info(msg[1].format(os.path.abspath(source_trimmed_csv)))

	# Write artwork types to a .csv file.
	artwork_types = extract_filtered_series(source_data_frame_trimmed, ['Object Name'])
	artwork_types_csv = os.path.join('output', 'met_artwork', 'met_artwork_types.csv')
	write_series_to_csv(artwork_types, artwork_types_csv, '\t', False)
	logging.info(msg[2].format(os.path.abspath(artwork_types_csv)))

	# Write cities and countries (the latter will be replaced with a FK) to a .csv file.
	cities = extract_filtered_series(source_data_frame_trimmed, ['City','Country'])
	cities_csv = os.path.join('output', 'met_artwork', 'met_cities.csv')
	write_series_to_csv(cities, cities_csv, '\t', False)
	logging.info(msg[8].format(os.path.abspath(cities_csv)))

	# Write regions and countries (the latter will be replaced with a FK) to a .csv file.
	regions = extract_filtered_series(source_data_frame_trimmed, ['Region','Country'])
	regions_csv = os.path.join('output', 'met_artwork', 'met_regions.csv')
	write_series_to_csv(regions, regions_csv, '\t', False)
	logging.info(msg[14].format(os.path.abspath(regions_csv)))

	# Write classification to a .csv file.
	classifications = extract_filtered_series(source_data_frame_trimmed, ['Classification'])
	classifications_csv = os.path.join('output', 'met_artwork', 'met_classifications.csv')
	write_series_to_csv(classifications, classifications_csv, '\t', False)
	logging.info(msg[9].format(os.path.abspath(classifications_csv)))

	# Write countries to a .csv file.
	countries = extract_filtered_series(source_data_frame_trimmed, ['Country'])
	countries_csv = os.path.join('output', 'met_artwork', 'met_countries.csv')
	write_series_to_csv(countries, countries_csv, '\t', False)
	logging.info(msg[10].format(os.path.abspath(countries_csv)))

	# Write departments to a .csv file
	departments = extract_filtered_series(source_data_frame_trimmed, ['Department'])
	departments_csv = os.path.join('output', 'met_artwork', 'met_departments.csv')
	write_series_to_csv(departments, departments_csv, '\t', False)
	logging.info(msg[11].format(os.path.abspath(departments_csv)))


def extract_filtered_series(data_frame, column_list):
	"""
	Returns a filtered Panda Series one-dimensional ndarray from a targeted column.
	Duplicate values and NaN or blank values are dropped from the result set which is
	returned sorted (ascending).
	:param data_frame: Pandas DataFrame
	:param column_list: list of columns
	:return: Panda Series one-dimensional ndarray
	"""

	return data_frame[column_list].drop_duplicates().dropna(axis=0, how='all').sort_values(
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
