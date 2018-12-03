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
		'Source file read and trimmed version written to file {0}',
		'Genres written to file {0}',
		'Platforms written to file {0}',
		'Publishers written to file {0}',
		'Ratings written to file {0}',
		'Developers written to file {0}'
	]

	# Setting logging format and default level
	logging.basicConfig(format='%(levelname)s: %(message)s', level=logging.DEBUG)

	# Read in source
	source_path = os.path.join('input', 'csv', 'video_game_sales-20161222.csv')
	source_data_frame = read_csv(source_path, ',')
	source_data_frame_trimmed = trim_columns(source_data_frame)
	source_trimmed_csv = os.path.join('output', 'video_games', 'video_game_sales_trimmed.csv')
	write_series_to_csv(source_data_frame_trimmed, source_trimmed_csv, ',', False)
	logging.info(msg[0].format(os.path.abspath(source_trimmed_csv)))

	# Write genre to a .csv file.
	genre = extract_filtered_series(source_data_frame_trimmed, 'genre_name')
	genre_csv = os.path.join('output', 'video_games', 'video_game_genres.csv')
	write_series_to_csv(genre, genre_csv, ',', False)
	logging.info(msg[1].format(os.path.abspath(genre_csv)))

	# Write platform to a .csv file.
	platform = extract_filtered_series(source_data_frame_trimmed, 'platform_name')
	platform_csv = os.path.join('output', 'video_games', 'video_game_platforms.csv')
	write_series_to_csv(platform, platform_csv, ',', False)
	logging.info(msg[2].format(os.path.abspath(platform_csv)))

	# Write publisher to a .csv file.
	publisher = extract_filtered_series(source_data_frame_trimmed, 'publisher_name')
	publisher_csv = os.path.join('output', 'video_games', 'video_game_publishers.csv')
	write_series_to_csv(publisher, publisher_csv, ',', False)
	logging.info(msg[3].format(os.path.abspath(publisher_csv)))

	# Write rating to a .csv file.
	rating = extract_filtered_series(source_data_frame_trimmed, 'rating_name')
	rating_csv = os.path.join('output', 'video_games', 'video_game_ratings.csv')
	write_series_to_csv(rating, rating_csv, ',', False)
	logging.info(msg[4].format(os.path.abspath(rating_csv)))

	# Write developer to a .csv file.
	developer = extract_filtered_series(source_data_frame_trimmed, 'developer_name')
	developer_csv = os.path.join('output', 'video_games', 'video_game_developers.csv')
	write_series_to_csv(developer, developer_csv, ',', False)
	logging.info(msg[5].format(os.path.abspath(developer_csv)))


def extract_filtered_series(data_frame, column_name):
	"""
	Returns a filtered Panda Series one-dimensional ndarray from a targeted column.
	Duplicate values and NaN or blank values are dropped from the result set which is
	returned sorted (ascending).
	:param data_frame: Pandas DataFrame
	:param column_name: column name string
	:return: Panda Series one-dimensional ndarray
	"""

	return data_frame[column_name].str.strip().drop_duplicates().dropna().sort_values()
    # return data_frame[column_name].drop_duplicates().dropna().sort_values()


def read_csv(path, delimiter=','):
	"""
    Utilize Pandas to read in *.csv file.
    :param path: file path
    :param delimiter: field delimiter
    :return: Pandas DataFrame
    """
	# return pd.read_csv(path, sep=delimiter, engine='python')
	# return pd.read_csv(path, sep=delimiter, encoding='ISO-8859-1', engine='python')
	return pd.read_csv(path, sep=delimiter, encoding='utf-8', engine='python')


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