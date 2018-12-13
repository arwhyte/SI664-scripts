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
        'Source file encoding detected = {0}',
        'Source file read and trimmed version written to file {0}',
        'Movies written to file {0}',
        'Directors written to file {0}',
        'Actor_1 written to file {0}',
        'Actor_2 written to file {0}',
        'Actor_3 written to file {0}',
        'Unique genres written to file {0}',
        'Movie genres written to file {0}',
        'Unique plot keywords written to file {0}',
        'Movie plot keywords written to file {0}',
        'Country written to file {0}',
        'Movie country written to file {0}',
        'language written to file {0}',
        'Movie language written to file {0}',
        'Rating written to file {0}',
        'Movie rating written to file {0}'
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
    source_out = os.path.join('output', 'movies', 'movie_metadata-trimmed.csv')
    write_series_to_csv(source_trimmed, source_out, ',', False)
    logging.info(msg[1].format(os.path.abspath(source_out)))

    # TODO
    # Create a movies.csv file with movie properties only
    movie = extract_filtered_series(
        source_trimmed,
        [
            'movie_title',
            'title_year',
            'imdb_score',
            'duration',
            'num_critic_for_reviews',
            'gross',
            'budget',
            'movie_facebook_likes',
            'movie_imdb_link',
        ],
    )
    movie['movie_title'] = movie['movie_title'].astype(str)
    movie_out = os.path.join('output', 'movies', 'movies.csv')
    write_series_to_csv(movie, movie_out, ',', False)
    logging.info(msg[2].format(os.path.abspath(movie_out)))

    directors = source_trimmed[['director_name', 'director_facebook_likes']] \
        .dropna(axis=0, subset=['director_name']) \
        .drop_duplicates(subset=['director_name']) \
        .sort_values(by=['director_name'])
    directors_out = os.path.join('output', 'movies', 'directors.csv')
    write_series_to_csv(directors, directors_out, ',', False)
    logging.info(msg[3].format(os.path.abspath(directors_out)))

    movie_directors = source_trimmed[['movie_title', 'director_name']] \
        .dropna(axis=0, subset=['director_name']) \
        .drop_duplicates(subset=['movie_title', 'director_name'])\
        .sort_values(by=['movie_title', 'director_name'])
    movie_directors['movie_title'] = movie_directors['movie_title'].astype(str)
    movie_directors_out = os.path.join('output', 'movies', 'movie_directors.csv')
    write_series_to_csv(movie_directors, movie_directors_out, ',', False)
    logging.info(msg[3].format(os.path.abspath(movie_directors_out)))

    actor_1 = source_trimmed[['movie_title', 'actor_1_name', 'actor_1_facebook_likes']] \
        .dropna(axis=0, subset=['actor_1_name']) \
        .drop_duplicates(subset=['movie_title', 'actor_1_name'])\
        .sort_values(by=['movie_title', 'actor_1_name'])
    actor_1['movie_title'] = actor_1['movie_title'].astype(str)
    actor_1_out = os.path.join('output', 'movies', 'actor_1.csv')
    write_series_to_csv(actor_1, actor_1_out, ',', False)
    logging.info(msg[4].format(os.path.abspath(actor_1_out)))

    # Repeat for actors 2 and 3.
    actor_2 = source_trimmed[['movie_title', 'actor_2_name', 'actor_2_facebook_likes']] \
        .dropna(axis=0, subset=['actor_2_name']) \
        .drop_duplicates(subset=['movie_title', 'actor_2_name'])\
        .sort_values(by=['movie_title', 'actor_2_name'])
    actor_2['movie_title'] = actor_2['movie_title'].astype(str)
    actor_2_out = os.path.join('output', 'movies', 'actor_2.csv')
    write_series_to_csv(actor_2, actor_2_out, ',', False)
    logging.info(msg[5].format(os.path.abspath(actor_2_out)))

    actor_3 = source_trimmed[['movie_title', 'actor_3_name', 'actor_3_facebook_likes']] \
        .dropna(axis=0, subset=['actor_3_name']) \
        .drop_duplicates(subset=['movie_title', 'actor_3_name'])\
        .sort_values(by=['movie_title', 'actor_3_name'])
    actor_3['movie_title'] = actor_3['movie_title'].astype(str)
    actor_3_out = os.path.join('output', 'movies', 'actor_3.csv')
    write_series_to_csv(actor_3, actor_3_out, ',', False)
    logging.info(msg[6].format(os.path.abspath(actor_3_out)))

    # Create column with list of keywords then melt to rows
    # genres = pd.DataFrame(columns=['genres'])
    genres = extract_filtered_series(source_trimmed, ['genres'])
    genres['genres'] = genres['genres'].str.split('|', n=-1, expand=False)
    genres_split = genres['genres'].apply(pd.Series)\
        .reset_index()\
        .melt(id_vars=['index'], value_name='genre')\
        .dropna(axis=0, how='any')[['index', 'genre']]\
        .drop_duplicates(subset=['genre'])\
        .set_index('index')\
        .sort_values(by=['genre'])

    genres_out = os.path.join('output', 'movies', 'genres_unique.csv')
    write_series_to_csv(genres_split, genres_out, ',', False)
    logging.info(msg[7].format(os.path.abspath(genres_out)))

    # Store the movie - genres associations vertically (M2M)
    # First convert genres pipe delimited string to a list, then do the merge and melt.
    # movie has no genres listed drop the row
    movie_genres = source_trimmed[['movie_title', 'genres']]\
        .dropna(axis=0, subset=['genres']) \
        .drop_duplicates(subset=['movie_title', 'genres']) \
        .sort_values(by=['movie_title', 'genres'])
    movie_genres['movie_title'] = movie_genres['movie_title'].astype(str)
    movie_genres['genres'] = movie_genres['genres'].str.split('|', n=-1, expand=False)
    movie_genres_split = movie_genres.genres.apply(pd.Series)\
        .merge(movie_genres, left_index=True, right_index=True)\
        .drop(['genres'], axis=1)\
        .melt(id_vars=['movie_title'], value_name='genre')\
        .drop('variable', axis=1) \
        .dropna(axis=0, subset=['genre']) \
        .drop_duplicates(subset=['movie_title', 'genre'])\
        .sort_values(by=['movie_title', 'genre'])
    movie_genres_out = os.path.join('output', 'movies', 'movie_genres-split.csv')
    write_series_to_csv(movie_genres_split, movie_genres_out, ',', False)
    logging.info(msg[8].format(os.path.abspath(movie_genres_out)))

    # Create column with list of keywords then melt to rows
    # keywords = pd.DataFrame(columns=['plot_keywords'])
    keywords = extract_filtered_series(source_trimmed, ['plot_keywords'])
    keywords['plot_keywords'] = keywords['plot_keywords'].str.split('|', n=-1, expand=False)
    keywords_split = keywords['plot_keywords'].apply(pd.Series)\
        .reset_index()\
        .melt(id_vars=['index'], value_name='plot_keyword')\
        .dropna(axis=0, how='any')[['index', 'plot_keyword']]\
        .drop_duplicates(subset=['plot_keyword'])\
        .set_index('index')\
        .sort_values(by=['plot_keyword'])
    keywords_out = os.path.join('output', 'movies', 'keywords_unique.csv')
    write_series_to_csv(keywords_split, keywords_out, ',', False)
    logging.info(msg[9].format(os.path.abspath(keywords_out)))

    # Store the movie - keyword associations vertically (M2M)
    # First convert keywords pipe delimited string to a list, then do the merge and melt.
    # movie has no keywords listed drop the row
    movie_keywords = source_trimmed[['movie_title', 'plot_keywords']]\
        .dropna(axis=0, subset=['plot_keywords']) \
        .drop_duplicates(subset=['movie_title', 'plot_keywords']) \
        .sort_values(by=['movie_title', 'plot_keywords'])
    movie_keywords['movie_title'] = movie_keywords['movie_title'].astype(str)
    movie_keywords['plot_keywords'] = movie_keywords['plot_keywords'].str.split('|', n=-1, expand=False)
    movie_keywords_split = movie_keywords.plot_keywords.apply(pd.Series)\
        .merge(movie_keywords, left_index=True, right_index=True)\
        .drop(['plot_keywords'], axis=1)\
        .melt(id_vars=['movie_title'], value_name='plot_keyword')\
        .drop('variable', axis=1)\
        .dropna(axis=0, subset=['plot_keyword'])\
        .drop_duplicates(subset=['movie_title', 'plot_keyword'])\
        .sort_values(by=['movie_title'])
    movie_keywords_out = os.path.join('output', 'movies', 'movie_keywords-split.csv')
    write_series_to_csv(movie_keywords_split, movie_keywords_out, ',', False)
    logging.info(msg[10].format(os.path.abspath(movie_keywords_out)))

    # country table
    country = extract_filtered_series(source_trimmed, ['country'])
    country_out = os.path.join('output', 'movies', 'country.csv')
    write_series_to_csv(country, country_out, ',', False)
    logging.info(msg[11].format(os.path.abspath(country_out)))

    # movie_country temp table
    movie_country = source_trimmed[['movie_title', 'country']] \
        .dropna(axis=0, subset=['country']) \
        .drop_duplicates(subset=['movie_title', 'country'])\
        .sort_values(by=['movie_title', 'country'])
    movie_country['movie_title'] = movie_country['movie_title'].astype(str)
    movie_country_out = os.path.join('output', 'movies', 'movie_country.csv')
    write_series_to_csv(movie_country, movie_country_out, ',', False)
    logging.info(msg[12].format(os.path.abspath(movie_country_out)))

    # language table
    language = extract_filtered_series(source_trimmed, ['language'])
    language_out = os.path.join('output', 'movies', 'language.csv')
    write_series_to_csv(language, language_out, ',', False)
    logging.info(msg[13].format(os.path.abspath(language_out)))

    # movie_language temp table
    movie_language = source_trimmed[['movie_title', 'language']] \
        .dropna(axis=0, subset=['language']) \
        .drop_duplicates(subset=['movie_title', 'language'])\
        .sort_values(by=['movie_title', 'language'])
    movie_language['movie_title'] = movie_language['movie_title'].astype(str)
    movie_language_out = os.path.join('output', 'movies', 'movie_language.csv')
    write_series_to_csv(movie_language, movie_language_out, ',', False)
    logging.info(msg[14].format(os.path.abspath(movie_country_out)))

    # rating table
    rating = extract_filtered_series(source_trimmed, ['content_rating'])
    rating_out = os.path.join('output', 'movies', 'rating.csv')
    write_series_to_csv(rating, rating_out, ',', False)
    logging.info(msg[15].format(os.path.abspath(rating_out)))

    # movie_rating temp table
    movie_rating = source_trimmed[['movie_title', 'content_rating']] \
        .dropna(axis=0, subset=['content_rating']) \
        .drop_duplicates(subset=['movie_title', 'content_rating'])\
        .sort_values(by=['movie_title', 'content_rating'])
    movie_rating['movie_title'] = movie_rating['movie_title'].astype(str)
    movie_rating_out = os.path.join('output', 'movies', 'movie_rating.csv')
    write_series_to_csv(movie_rating, movie_rating_out, ',', False)
    logging.info(msg[16].format(os.path.abspath(movie_rating_out)))


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
