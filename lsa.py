import numpy as np
import pandas as pd

from datetime import datetime
import string

import pymongo
from pymongo import MongoClient

from bs4 import BeautifulSoup
from collections import Counter

from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize
from nltk.stem import SnowballStemmer
from nltk.stem.porter import PorterStemmer

from sklearn.pipeline import Pipeline, make_pipeline
from sklearn.preprocessing import Normalizer
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.decomposition import TruncatedSVD
from sklearn.metrics.pairwise import cosine_similarity, linear_kernel


def get_data(cursor):
    attributes = ['slug', 'synopsis']
    results = []
    for i, x in enumerate(cursor):
        print i, x['slug'], x['averageRating']
        results.append([x[k] for k in attributes])

    df = pd.DataFrame(results, columns=attributes)
    return df


def process_text(text, exclusions):
    tokens = [s.lower() for s in word_tokenize(text)]
    stemmer = PorterStemmer()
    processed = [stemmer.stem(t) for t in tokens]
    return tokens


class StemmerTokenizer(object):
    def __init__(self):
        self.stemmer = SnowballStemmer('english')
        # self.stemmer = PorterStemmer()

    def mapper(self, word):
        return self.stemmer.stem(word)

    def tokenizer(self, doc):
        # p = string.punctuation
        # return [self.mapper(s) for s in word_tokenize(doc) if s not in p]
        # return [s for s in word_tokenize(doc) if s not in p]
        # return [x for x in word_tokenize(doc)]
        return doc

    def preprocessor(self, line):
        return line.lower()


if __name__ == '__main__':
    client = MongoClient()
    db = client.kitsu
    cursor = db.anime.find()

    df = get_data(cursor)
    y = df.slug.values
    # X = asdf

    tokenizer = StemmerTokenizer()
    pipeline = make_pipeline(
        TfidfVectorizer(
            # preprocessor=tokenizer.preprocessor,
            # tokenizer=tokenizer.tokenizer,
            analyzer='word',
            ngram_range=(1, 3),
            min_df=0,
            stop_words='english'
        ),
        TruncatedSVD(n_components=100),
        Normalizer(copy=False)
    )
    X = pipeline.fit_transform(df.synopsis)
    cs = cosine_similarity(X)

    # using linear_kernel to calculate cosine similarity
    tfidf_vector = TfidfVectorizer(
        # preprocessor=tokenizer.preprocessor,
        # tokenizer=tokenizer.tokenizer,
        analyzer='word',
        ngram_range=(1, 3),
        min_df=0,
        stop_words='english'
    )
    tfidf_matrix = tfidf_vector.fit_transform(df.synopsis)
    cs_lk = linear_kernel(tfidf_matrix, tfidf_matrix)

    def recommend(index, cs, y, n=5):
        a = np.argsort(cs, axis=1)[index][::-1][1:n + 1]
        return zip(y[a], cs[index][a])

    index = 1525
    print '\ncosine_similarity: %s' % y[index]
    for k, v in recommend(index, cs, y, 10):
        print '%s: %.4f' % (k, v)

    print '\ncosine_similarity (linear_kernel): %s' % y[index]
    for k, v in recommend(index, cs_lk, y, 10):
        print '%s: %.4f' % (k, v)
