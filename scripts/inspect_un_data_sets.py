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
		'Source file read {0}',
		'UNSD M49 regions written to file {0}',
		'UNSD M49 sub-regions written to file {0}',
		'UNSD M49 intermediate regions written to file {0}',
		'UNSD M49 countries and areas written to file {0}',
		'UNSD M49 development status written to file {0}',
		'UNESCO heritage site countries/areas written to file {0}',
		'UNESCO heritage site categories written to file {0}',
		'UNESCO heritage site regions written to file {0}',
		'UNESCO heritage site transboundary values written to file {0}'
	]

	# Setting logging format and default level
	logging.basicConfig(format='%(levelname)s: %(message)s', level=logging.DEBUG)

	# Read in United Nations Statistical Division (UNSD) M49 Standard data set (tabbed separator)
	unsd_csv = './input/csv/un_area_country_codes-m49.csv'
	unsd_data_frame = read_csv(unsd_csv, '\t')
	logging.info(msg[0].format(os.path.abspath(unsd_csv)))

	# Write regions to a .csv file.
	unsd_region = extract_filtered_series(unsd_data_frame, 'region_name')
	unsd_region_csv = './output/unsd_region.csv'
	write_series_to_csv(unsd_region, unsd_region_csv, '\t', False)
	logging.info(msg[1].format(os.path.abspath(unsd_region_csv)))

	# Write sub-regions to a .csv file.
	unsd_sub_region = extract_filtered_series(unsd_data_frame, 'sub_region_name')
	unsd_sub_region_csv = './output/unsd_sub_region.csv'
	write_series_to_csv(unsd_sub_region, unsd_sub_region_csv, '\t', False)
	logging.info(msg[2].format(os.path.abspath(unsd_sub_region_csv)))

	# Write intermediate_regions to a .csv file.
	unsd_intermed_region = extract_filtered_series(unsd_data_frame, 'intermediate_region_name')
	unsd_intermed_region_csv = './output/unsd_intermed_region.csv'
	write_series_to_csv(unsd_intermed_region, unsd_intermed_region_csv, '\t', False)
	logging.info(msg[3].format(os.path.abspath(unsd_intermed_region_csv)))

	# Write countries or areas to a .csv file.
	unsd_country_area = extract_filtered_series(unsd_data_frame, 'country_area_name')
	unsd_country_area_csv = './output/unsd_country_area.csv'
	write_series_to_csv(unsd_country_area, unsd_country_area_csv, '\t', False)
	logging.info(msg[4].format(os.path.abspath(unsd_country_area_csv)))

	# Write development status to a .csv file.
	unsd_dev_status = extract_filtered_series(unsd_data_frame, 'country_area_development_status')
	unsd_dev_status_csv = './output/unsd_dev_status.csv'
	write_series_to_csv(unsd_dev_status, unsd_dev_status_csv, '\t', False)
	logging.info(msg[5].format(os.path.abspath(unsd_dev_status_csv)))

	# Read UNESCO heritage sites data (tabbed separator)
	unesco_csv = './input/csv/unesco_heritage_sites.csv'
	unesco_data_frame = read_csv(unesco_csv, '\t')
	logging.info(msg[0].format(os.path.abspath(unesco_csv)))

	# Write UNESCO heritage site countries and areas to a .csv file
	unesco_country_area = extract_filtered_series(unesco_data_frame, 'country_area')
	unesco_country_area_csv = './output/unesco_heritage_site_country_area.csv'
	write_series_to_csv(unesco_country_area, unesco_country_area_csv, '\t', False)
	logging.info(msg[6].format(os.path.abspath(unesco_country_area_csv)))

	# Write UNESCO heritage site categories to a .csv file
	unesco_site_category = extract_filtered_series(unesco_data_frame, 'category')
	unesco_site_category_csv = './output/unesco_heritage_site_category.csv'
	write_series_to_csv(unesco_site_category, unesco_site_category_csv, '\t', False)
	logging.info(msg[7].format(os.path.abspath(unesco_site_category_csv)))

	# Write UNESCO heritage site regions to a .csv file
	unesco_region = extract_filtered_series(unesco_data_frame, 'region')
	unesco_region_csv = './output/unesco_heritage_site_region.csv'
	write_series_to_csv(unesco_region, unesco_region_csv, '\t', False)
	logging.info(msg[8].format(os.path.abspath(unesco_region_csv)))

	# Write UNESCO heritage site transboundary values to a .csv file
	unesco_transboundary = extract_filtered_series(unesco_data_frame, 'transboundary')
	unesco_transboundary_csv = './output/unesco_heritage_site_transboundary.csv'
	write_series_to_csv(unesco_transboundary, unesco_transboundary_csv, '\t', False)
	logging.info(msg[9].format(os.path.abspath(unesco_transboundary_csv)))


def extract_filtered_series(data_frame, column_name):
	"""
	Returns a filtered Panda Series one-dimensional ndarray from a targeted column.
	Duplicate values and NaN or blank values are dropped from the result set which is
	returned sorted (ascending).
	:param data_frame: Pandas DataFrame
	:param column_name: column name string
	:return: Panda Series one-dimensional ndarray
	"""
	return data_frame[column_name].drop_duplicates().dropna().sort_values()


def read_csv(path, delimiter=','):
	"""
	Utilize Pandas to read in *.csv file.
	:param path: file path
	:param delimiter: field delimiter
	:return: Pandas DataFrame
	"""
	return pd.read_csv(path, sep=delimiter, encoding='utf-8', engine='python')


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