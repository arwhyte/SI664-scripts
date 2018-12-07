import chardet
import logging
import os
import pandas as pd
import sys as sys


def main(argv=None):
	"""
	Utilize Pandas library to read in  DRG_Prices.csv file
	(tab delimited) hospital information .csv file (tab delimited).
	Extract regions, sub-regions, intermediate regions, country and areas, and
	other column data.  Filter out duplicate values and NaN values and sort the
	series in alphabetical order. Write out each series to a .csv file for inspection.
	"""
	if argv is None:
		argv = sys.argv

	msg = [
		'Source file read {0}',	#0
		'DRG Prices DRG Code written to file {0}',	#1
		'DRG Prices DRG Definition written to file {0}',	#2
		'DRG Prices Hospital Street Address written to file {0}',	#3
		'DRG Prices Hospital Zip Code written to file {0}',	#4				
		'DRG Prices Average Covered Charges written to file {0}',	#5
		'Hospital Information: Name written to file {0}',	#6
		'Hospital Information: Address  written to file {0}',	#7
		'Hospital Information: City written to file {0}',		#8
		'Hospital Information: State written to file {0}',		#9
		'Hospital Information: Zip Code written to file {0}',		#10
		'Hospital Information: Hospital Ownership written to file {0}',	#11
		'Hospital Information: Hospital Overall Score written to file {0}',	#12
		'Hospital Information: Hospital Safety Score written to file {0}',	#13	
		'Hospital Information: Hospital Readmission Score written to file {0}',	#14		
		'Poverty Zip Code written to file {0}',	#15
		'Poverty Zip Code Designation written to file {0}'	#16
	]

	# Setting logging format and default level
	logging.basicConfig(format='%(levelname)s: %(message)s', level=logging.DEBUG)

	# Read Hospital Information data (check encoding)
	hospital_info_csv = './input/csv/hospital_info.csv'
	encoding = find_encoding(hospital_info_csv)
	hospital_data_frame_b = read_csv(hospital_info_csv, encoding, ',')

	hospital_data_frame = trim_columns(hospital_data_frame_b)
	csv = './output/hospitals/hospital_info_trimmed.csv'
	write_series_to_csv(hospital_data_frame, csv, ',', False)
	logging.info(msg[0].format(os.path.abspath(hospital_info_csv)))

	# Write hospital name to a .csv file
	hosp_name = extract_filtered_series(hospital_data_frame, ['Hospital Name'])
	hosp_name_csv = './output/hospitals/hosp_name.csv'
	write_series_to_csv(hosp_name, hosp_name_csv, ',', False)
	logging.info(msg[6].format(os.path.abspath(hosp_name_csv)))

	# Write hospital address to a .csv file
	hosp_address = extract_filtered_series(hospital_data_frame, ['Address'])
	hosp_address_csv = './output/hospitals/hosp_address.csv'
	write_series_to_csv(hosp_address, hosp_address_csv, ',', False)
	logging.info(msg[7].format(os.path.abspath(hosp_address_csv)))

	# Write hospital city to a .csv file
	hosp_city = extract_filtered_series(hospital_data_frame, ['City'])
	hosp_city_csv = './output/hospitals/hosp_city.csv'
	write_series_to_csv(hosp_city, hosp_city_csv, ',', False)
	logging.info(msg[8].format(os.path.abspath(hosp_city_csv)))

	# Write hospital state to a .csv file
	hosp_state = extract_filtered_series(hospital_data_frame, ['State'])
	hosp_state_csv = './output/hospitals/hosp_state.csv'
	write_series_to_csv(hosp_state, hosp_state_csv, ',', False)
	logging.info(msg[9].format(os.path.abspath(hosp_state_csv)))

	# Write hospital zip code to a .csv file
	hosp_zip = extract_filtered_series(hospital_data_frame, ['ZIP Code'])
	hosp_zip_csv = './output/hospitals/hosp_zip.csv'
	write_series_to_csv(hosp_zip, hosp_zip_csv, ',', False)
	logging.info(msg[10].format(os.path.abspath(hosp_zip_csv)))

	# Write hospital type to a .csv file
	hosp_type = extract_filtered_series(hospital_data_frame, ['Hospital Type'])
	hosp_type_csv = './output/hospitals/hosp_type.csv'
	write_series_to_csv(hosp_type, hosp_type_csv, ',', False)
	logging.info(msg[11].format(os.path.abspath(hosp_type_csv)))

	# Write hospital ownership to a .csv file
	hosp_owner = extract_filtered_series(hospital_data_frame, ['Hospital Ownership'])
	hosp_owner_csv = './output/hospitals/hosp_owner.csv'
	write_series_to_csv(hosp_owner, hosp_owner_csv, ',', False)
	logging.info(msg[11].format(os.path.abspath(hosp_owner_csv)))

	# Write hospital overall rating to a .csv file
	hosp_score = extract_filtered_series(hospital_data_frame, ['Hospital overall rating'])
	hosp_score_csv = './output/hospitals/hosp_score.csv'
	write_series_to_csv(hosp_score, hosp_score_csv, ',', False)
	logging.info(msg[12].format(os.path.abspath(hosp_score_csv)))

	# Write hospital safety of care national comparison to a .csv file
	# hosp_safety = extract_filtered_series(hospital_data_frame, ['safety_rating'])
	# hosp_safety_csv = './output/hospitals/hosp_safety.csv'
	# write_series_to_csv(hosp_safety, hosp_safety_csv, ',', False)
	# logging.info(msg[13].format(os.path.abspath(hosp_safety_csv)))

	# Write hospital readmission rate national comparison to a .csv file
	# hosp_readmit = extract_filtered_series(hospital_data_frame, ['readmission_rate'])
	# hosp_readmit_csv = './output/hospitals/hosp_readmit.csv'
	#write_series_to_csv(hosp_readmit, hosp_readmit_csv, ',', False)
	# logging.info(msg[14].format(os.path.abspath(hosp_readmit_csv)))

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