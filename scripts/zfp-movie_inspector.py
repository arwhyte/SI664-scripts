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
		'Source file encoding detected = {0}',
		'Source file read and trimmed version written to file {0}',
		'Directors written to file {0}',
		'Actor_1 written to file {0}',
		'Unique genres written to file {0}',
		'Movie genres written to file {0}',
		'Unique plot keywords written to file {0}',
		'Movie plot keywords written to file {0}'
	]

	# Setting logging format and default level
	logging.basicConfig(format='%(levelname)s: %(message)s', level=logging.DEBUG)

	# Check source file encoding
	source_in = os.path.join('input', 'csv', 'zfp-movie_metadata.csv')
	encoding = find_encoding(source_in)
	logging.info(msg[0].format(encoding))

	# Read in source with correct encoding and remove whitespace.
	source = read_csv(source_in, encoding, ',')
	source_trimmed = trim_columns(source)
	source_out = os.path.join('output', 'movies', 'zfp-movie_metadata-trimmed.csv')
	write_series_to_csv(source_trimmed, source_out, ',', False)
	logging.info(msg[1].format(os.path.abspath(source_out)))


	# TODO
	# Create a zfp-movies.csv file with movie properties only


	directors = extract_filtered_series(source_trimmed, [
		'movie_title',
		'director_name',
		'director_facebook_likes'
	])
	directors_out = os.path.join('output', 'movies', 'zfp-directors.csv')
	write_series_to_csv(directors, directors_out, ',', False)
	logging.info(msg[2].format(os.path.abspath(directors_out)))

	actor_1 = extract_filtered_series(source_trimmed, [
		'movie_title',
		'actor_1_name',
		'actor_1_facebook_likes'
	])
	actor_1_out = os.path.join('output', 'movies', 'zfp-actor_1.csv')
	write_series_to_csv(actor_1, actor_1_out, ',', False)
	logging.info(msg[3].format(os.path.abspath(actor_1_out)))


	# TODO
	# Repeat for actors 2 and 3.
	

	# Create column with list of keywords then melt to rows
	# genres = pd.DataFrame(columns=['genres'])
	genres = extract_filtered_series(source_trimmed, ['genres'])
	genres['genres'] = genres['genres'].str.split('|', n=-1, expand=False)
	genres_split = genres['genres'].apply(pd.Series) \
		.reset_index() \
		.melt(id_vars=['index'], value_name='genre') \
		.dropna()[['index', 'genre']] \
		.drop_duplicates(subset=['genre']) \
		.set_index('index') \
		.sort_values(by=['genre'])
	genres_out = os.path.join('output', 'movies', 'zfp-genres_unique.csv')
	write_series_to_csv(genres_split, genres_out, ',', False)
	logging.info(msg[4].format(os.path.abspath(genres_out)))

	# Store the movie - genres associations vertically
	# First convert genres pipe delimited string to a list, then do the merge and melt.
	movie_genres = extract_filtered_series(source_trimmed, ['movie_title', 'genres'])
	movie_genres['genres'] = movie_genres['genres'].str.split('|', n=-1, expand=False)
	movie_genres_split = movie_genres.genres.apply(pd.Series)\
		.merge(movie_genres, left_index=True, right_index=True)\
		.drop(['genres'], axis=1)\
		.melt(id_vars=['movie_title'], value_name='genre')\
		.drop('variable', axis=1)\
		.dropna() \
		.drop_duplicates(subset=['movie_title', 'genre']) \
		.sort_values(by=['movie_title'])
	movie_genres_out = os.path.join('output', 'movies', 'zfp-movie_genres-split.csv')
	write_series_to_csv(movie_genres_split, movie_genres_out, ',', False)
	logging.info(msg[5].format(os.path.abspath(movie_genres_out)))

	# Create column with list of keywords then melt to rows
	# keywords = pd.DataFrame(columns=['plot_keywords'])
	keywords = extract_filtered_series(source_trimmed, ['plot_keywords'])
	keywords['plot_keywords'] = keywords['plot_keywords'].str.split('|', n=-1, expand=False)
	keywords_split = keywords['plot_keywords'].apply(pd.Series)\
		.reset_index()\
		.melt(id_vars=['index'], value_name='plot_keyword')\
		.dropna()[['index', 'plot_keyword']]\
		.drop_duplicates(subset=['plot_keyword'])\
		.set_index('index')\
		.sort_values(by=['plot_keyword'])
	keywords_out = os.path.join('output', 'movies', 'zfp-keywords_unique.csv')
	write_series_to_csv(keywords_split, keywords_out, ',', False)
	logging.info(msg[6].format(os.path.abspath(keywords_out)))

	# Store the movie - keyword associations vertically
	# First convert keywords pipe delimited string to a list, then do the merge and melt.
	movie_keywords = extract_filtered_series(source_trimmed, ['movie_title', 'plot_keywords'])
	movie_keywords['plot_keywords'] = movie_keywords['plot_keywords'].str.split('|', n=-1, expand=False)
	movie_keywords_split = movie_keywords.plot_keywords.apply(pd.Series)\
		.merge(movie_keywords, left_index=True, right_index=True)\
		.drop(['plot_keywords'], axis=1)\
		.melt(id_vars=['movie_title'], value_name='plot_keyword')\
		.drop('variable', axis=1)\
		.dropna() \
		.drop_duplicates(subset=['movie_title', 'plot_keyword'])\
		.sort_values(by=['movie_title'])
	movie_keywords_out = os.path.join('output', 'movies', 'zfp-movie_keywords-split.csv')
	write_series_to_csv(movie_keywords_split, movie_keywords_out, ',', False)
	logging.info(msg[7].format(os.path.abspath(movie_keywords_out)))

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
