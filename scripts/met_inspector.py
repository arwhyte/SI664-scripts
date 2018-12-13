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
		'Unique artists written to file {0}',
		'Artwork artists written to file {0}',
		'Unique roles written to file {0}',
		'Artwork artist roles written to file {0}',
		'Unique attributions written to file {0}',
		'Artwork attributions written to file {0}',
		'Cities written to file {0}',
		'Classifications written to file {0}',
		'Countries written to file {0}',
		'Departments written to file {0}',
		'Regions written to file {0}',
		'Repositories written to file {0}',
	]

	# Setting logging format and default level
	logging.basicConfig(format='%(levelname)s: %(message)s', level=logging.DEBUG)

	# Check source file encoding
	source_path = os.path.join('input', 'csv', 'met_cleaned_seroka-orig.xlsx')
	# source_path = os.path.join('input', 'csv', 'met_data_seroka-orig.csv')
	# encoding = find_encoding(source_path)
	# logging.info(msg[0].format(encoding))

	# Read in source with correct encoding and remove whitespace.
	source = pd.read_excel(source_path, sheet_name='all_data', header=0)
	# source = read_csv(source_path, encoding, '\t')
	source_trimmed = trim_columns(source)

	# Turned off as trimmed source file now includes manual fixes
	source_trimmed_csv = os.path.join('output', 'met_artwork', 'met_artwork-trimmed.csv')
	write_series_to_csv(source_trimmed, source_trimmed_csv, '\t', False)
	logging.info(msg[1].format(os.path.abspath(source_trimmed_csv)))

	# Write artwork types to a .csv file.
	artwork_types = extract_filtered_series(source_trimmed, ['Object Name'])
	artwork_types_csv = os.path.join('output', 'met_artwork', 'met_artwork_types.csv')
	write_series_to_csv(artwork_types, artwork_types_csv, '\t', False)
	logging.info(msg[2].format(os.path.abspath(artwork_types_csv)))

	artists = extract_filtered_series(source_trimmed, ['Artist Display Name'])
	artists['Artist Display Name'] = artists['Artist Display Name'].str.split('|', n=-1, expand=False)
	artists_split = artists['Artist Display Name'].apply(pd.Series) \
		.reset_index() \
		.melt(id_vars=['index'], value_name='artist') \
		.dropna(axis=0, how='any')[['index', 'artist']] \
		.drop_duplicates(axis=0, subset=['artist']) \
		.set_index('index') \
		.sort_values(by=['artist'])
	artists_out = os.path.join('output', 'met_artwork', 'met_artists_unique.csv')
	write_series_to_csv(artists_split, artists_out, ',', False)
	logging.info(msg[4].format(os.path.abspath(artists_out)))

	# Store the artwork artist associations vertically
	# First convert artwork_artists pipe delimited string to a list, then do the merge and melt.
	# Errors thrown on Object Number (Pandas can't decide if values are strings, floats or integers
	# sort_values() throws errors
	artwork_artists = source_trimmed[['Object Number', 'Artist Display Name']]\
		.dropna(axis=0, how='all')\
		.drop_duplicates(subset=['Object Number', 'Artist Display Name'])

	# Data intended for M2M junction table; rows with no artist listed can be dropped
	# Don't delete variable
	# .drop('variable', axis=1).
	# Use it as an index to match artists to roles, etc.
	artwork_artists['Object Number'] = artwork_artists['Object Number'].astype(str)
	artwork_artists['Artist Display Name'] = artwork_artists['Artist Display Name'].str.split('|', n=-1, expand=False)
	artwork_artists_split = artwork_artists['Artist Display Name'].apply(pd.Series) \
		.merge(artwork_artists, left_index=True, right_index=True) \
		.drop(['Artist Display Name'], axis=1) \
		.melt(id_vars=['Object Number'], value_name='artist') \
		.dropna(axis=0, subset=['artist']) \
		.drop_duplicates(axis=0, subset=['artist']) \
		.sort_values(by=['Object Number', 'variable'])
	artwork_artists_out = os.path.join(
		'output',
		'met_artwork',
		'met_artwork-artwork_artists-split.csv'
	)
	write_series_to_csv(artwork_artists_split, artwork_artists_out, ',', False)
	logging.info(msg[5].format(os.path.abspath(artwork_artists_out)))

	roles = extract_filtered_series(source_trimmed, ['Artist Role'])
	roles['Artist Role'] = roles['Artist Role'].str.split('|', n=-1, expand=False)
	roles_split = roles['Artist Role'].apply(pd.Series) \
		.reset_index() \
		.melt(id_vars=['index'], value_name='role') \
		.dropna(axis=0, how='any')[['index', 'role']] \
		.drop_duplicates(axis=0, subset=['role']) \
		.set_index('index') \
		.sort_values(by=['role'])
	roles_out = os.path.join('output', 'met_artwork', 'met_roles_unique.csv')
	write_series_to_csv(roles_split, roles_out, ',', False)
	logging.info(msg[6].format(os.path.abspath(roles_out)))

	# DO NOT filter out duplicate roles - 2+ artists associated with a work
	# can be assigned the same role.
	artwork_roles = source_trimmed[['Object Number', 'Artist Role']] \
		.dropna(axis=0, how='all')
	artwork_roles['Object Number'] = artwork_roles['Object Number'].astype(str)
	artwork_roles['Artist Role'] = artwork_roles['Artist Role'].str.split('|', n=-1, expand=False)
	artwork_roles_split = artwork_roles['Artist Role'].apply(pd.Series) \
		.merge(artwork_roles, left_index=True, right_index=True) \
		.drop(['Artist Role'], axis=1) \
		.melt(id_vars=['Object Number'], value_name='role') \
		.dropna(axis=0, subset=['role']) \
		.sort_values(by=['Object Number', 'variable'])
	artwork_roles_out = os.path.join(
		'output',
		'met_artwork',
		'met_artwork-artwork_roles-split.csv'
	)
	write_series_to_csv(artwork_roles_split, artwork_roles_out, ',', False)
	logging.info(msg[7].format(os.path.abspath(artwork_roles_out)))

	attribution = extract_filtered_series(source_trimmed, ['Artist Prefix'])
	attribution['Artist Prefix'] = attribution['Artist Prefix'].str.split('|', n=-1, expand=False)
	attribution_split = attribution['Artist Prefix'].apply(pd.Series) \
		.reset_index() \
		.melt(id_vars=['index'], value_name='attribution') \
		.dropna(axis=0, how='any')[['index', 'attribution']] \
		.drop_duplicates(axis=0, subset=['attribution']) \
		.set_index('index') \
		.sort_values(by=['attribution'])
	attribution_out = os.path.join('output', 'met_artwork', 'met_attribution_unique.csv')
	write_series_to_csv(attribution_split, attribution_out, ',', False)
	logging.info(msg[6].format(os.path.abspath(attribution_out)))

	# DO NOT filter out duplicate attributions - 2+ artists associated with a work
	# can be assigned the same attribution.
	artwork_attribution = source_trimmed[['Object Number', 'Artist Prefix']] \
		.dropna(axis=0, how='all')
	artwork_attribution['Object Number'] = artwork_attribution['Object Number'].astype(str)
	artwork_attribution['Artist Prefix'] = artwork_attribution['Artist Prefix'].str.split('|', n=-1, expand=False)
	artwork_attribution_split = artwork_attribution['Artist Prefix'].apply(pd.Series) \
		.merge(artwork_attribution, left_index=True, right_index=True) \
		.drop(['Artist Prefix'], axis=1) \
		.melt(id_vars=['Object Number'], value_name='attribution') \
		.dropna(axis=0, subset=['attribution']) \
		.sort_values(by=['Object Number', 'variable'])
	artwork_attribution_out = os.path.join(
		'output',
		'met_artwork',
		'met_artwork-artwork_attribution-split.csv'
	)
	write_series_to_csv(artwork_attribution_split, artwork_attribution_out, ',', False)
	logging.info(msg[7].format(os.path.abspath(artwork_attribution_out)))

	# Write cities and countries (the latter will be replaced with a FK) to a .csv file.
	cities = extract_filtered_series(source_trimmed, ['City', 'Country'])
	cities_csv = os.path.join('output', 'met_artwork', 'met_cities.csv')
	write_series_to_csv(cities, cities_csv, '\t', False)
	logging.info(msg[10].format(os.path.abspath(cities_csv)))

	# Write classification to a .csv file.
	classifications = extract_filtered_series(source_trimmed, ['Classification'])
	classifications_csv = os.path.join('output', 'met_artwork', 'met_classifications.csv')
	write_series_to_csv(classifications, classifications_csv, '\t', False)
	logging.info(msg[11].format(os.path.abspath(classifications_csv)))

	# Write countries to a .csv file.
	countries = extract_filtered_series(source_trimmed, ['Country'])
	countries_csv = os.path.join('output', 'met_artwork', 'met_countries.csv')
	write_series_to_csv(countries, countries_csv, '\t', False)
	logging.info(msg[12].format(os.path.abspath(countries_csv)))

	# Write departments to a .csv file
	departments = extract_filtered_series(source_trimmed, ['Department'])
	departments_csv = os.path.join('output', 'met_artwork', 'met_departments.csv')
	write_series_to_csv(departments, departments_csv, '\t', False)
	logging.info(msg[13].format(os.path.abspath(departments_csv)))

	# Write regions and countries (the latter will be replaced with a FK) to a .csv file.
	regions = extract_filtered_series(source_trimmed, ['Region', 'Country'])
	regions_csv = os.path.join('output', 'met_artwork', 'met_regions.csv')
	write_series_to_csv(regions, regions_csv, '\t', False)
	logging.info(msg[14].format(os.path.abspath(regions_csv)))

	# Write repositories to a .csv file
	repositories = extract_filtered_series(source_trimmed, ['Repository'])
	repositories_csv = os.path.join('output', 'met_artwork', 'met_repositories.csv')
	write_series_to_csv(repositories, repositories_csv, '\t', False)
	logging.info(msg[15].format(os.path.abspath(repositories_csv)))


def extract_filtered_series(data_frame, column_list):
	"""
	Returns a filtered Panda Series one-dimensional ndarray from a targeted column.
	Duplicate values and NaN or blank values are dropped from the result set which is
	returned sorted (ascending).
	:param data_frame: Pandas DataFrame
	:param column_list: list of columns
	:return: Panda Series one-dimensional ndarray
	"""

	return data_frame[column_list].drop_duplicates().dropna(axis=0, how='all')\
		.sort_values(by=column_list)
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
