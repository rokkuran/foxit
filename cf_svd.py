import numpy as np
import pandas as pd

import pymongo
from pymongo import MongoClient

import operator
from collections import Counter

from sklearn.metrics import mean_squared_error
from sklearn.metrics.pairwise import pairwise_distances
from sklearn.cluster import KMeans
from sklearn.decomposition import TruncatedSVD
from sklearn.utils.extmath import randomized_svd
from sklearn.model_selection import train_test_split


class UtilityMatrix(object):
    """"""
    def __init__(self):
        super(UtilityMatrix, self).__init__()
        client = MongoClient()
        self.collection = client.kitsu.users

        self.n_users = self.collection.count()
        self.anime_list = self.collection.distinct("library.anime_id")
        self.n_anime = len(self.anime_list)

        self.utility_matrix = np.nan * np.empty([self.n_users, self.n_anime])
        # self.utility_matrix = np.zeros([self.n_users, self.n_anime])
        self._create_utility_matrix()
        self._nan_loc = np.isnan(self.utility_matrix)

    def _create_utility_matrix(self):
        self.anime_id_title_map = {}  # uid is the utility_matrix column id
        self.username_uid_map = {}

        cursor = self.collection.find()
        for i, user in enumerate(cursor):
            username = user['name'].encode('utf-8')
            self.username_uid_map[username] = i
            for item in user['library']:
                anime_id = item['anime_id']
                title = item['title'].encode('utf-8')
                uid = self.anime_list.index(anime_id)

                if uid not in self.anime_id_title_map:
                    self.anime_id_title_map[uid] = title

                # rating = item['rating'] + 1  # offset to include real zeros
                rating = item['rating']

                self.utility_matrix[i, uid] = rating

        self.utility_matrix = pd.DataFrame(
            self.utility_matrix,
            columns=self.anime_list
        )


if __name__ == '__main__':
    um = UtilityMatrix()
    X = um.utility_matrix.as_matrix()
    X_train, X_test = train_test_split(X, test_size=0.1, random_state=77)

    item_mean = np.nanmean(X_train, axis=0)
    items_not_nan = np.isnan(item_mean)
    item_mean = item_mean[~items_not_nan]

    X_train = X_train[:, ~items_not_nan]

    user_mean = np.nanmean(X_train, axis=1)

    R = X_train.copy()
    for i, mu in enumerate(item_mean):
        R[:, i][np.isnan(R[:, i])] = mu

    R = R - user_mean[:, np.newaxis]

    U, s, V = randomized_svd(M=R, n_components=100, random_state=77)
    s = np.diag(s)

    Us = U.dot(np.sqrt(s).T)
    sV = np.sqrt(s).dot(V)

    user_sim = pairwise_distances(Us, metric='cosine')
    item_sim = pairwise_distances(sV.T, metric='cosine')

    i = 0
    n_sim = 10
    sim_index = item_sim[i].argsort()[1:n_sim + 1]
    sim = item_sim[i][sim_index]

    p = (sim * (R[:, sim_index] + user_mean[:, np.newaxis])).sum(axis=1)
    p /= np.abs(sim).sum()

    # TODO: expand, complete, refine.
