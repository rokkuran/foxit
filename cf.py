import numpy as np
import pandas as pd

import pymongo
from pymongo import MongoClient

import operator
from collections import Counter

from sklearn.metrics.pairwise import pairwise_distances
from sklearn.cluster import KMeans


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
        self._create_utility_matrix()
        self._nan_loc = np.isnan(self.utility_matrix)

    def _create_utility_matrix(self):
        self.anime_id_title_map = {}  # uid is the utility_matrix column id
        self.username_uid_map = {}

        # TODO: make min library entry count a parameter
        cursor = self.collection.find({'$where': 'this.library.length > 50'})
        # cursor = self.collection.find()
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


class CFMemory(UtilityMatrix):
    """
    Memory based collaborative filtering recommender.
    """
    def __init__(self):
        super(CFMemory, self).__init__()
        self._calc_similarity_matrices()

    def _calc_similarity_matrices(self, metric='cosine'):
        X = self.utility_matrix.as_matrix().copy()
        X[np.isnan(X)] = 0.0
        self.user_sim = pairwise_distances(X, metric=metric)

    def _user_rating_counts(self):
        return np.apply_along_axis(
            lambda x: len(x[~np.isnan(x)]), axis=1, arr=self.utility_matrix)

    def user_vector(self, username):
        uid = self.username_uid_map[username]
        return self.utility_matrix.iloc[uid].values

    def similar_users(self, username, n_pool, names=False):
        uid = self.username_uid_map[username]
        su_ids = np.argsort(self.user_sim[uid])[1:n_pool + 1]
        if names:
            uid_username_map = {v: k for k, v in self.username_uid_map.items()}
            return [uid_username_map[i] for i in su_ids]
        else:
            return su_ids

    def predict(self, username, n_rec, n_pool, method='mean'):
        u = self.user_vector(username)
        similar_users = self.similar_users(username, n_pool)
        q = self.utility_matrix.iloc[similar_users].as_matrix()

        if method == 'mean':
            predictions = self._predict_mean(u, q)
        elif method == 'mean_sim':
            predictions = self._predict_sim_mean(username, similar_users)
        else:
            raise Exception('predict method does not exist.')
        return predictions

    def _predict_mean(self, u, q):
        p = u.copy()
        for i, x in enumerate(u):
            if np.isnan(x):
                p[i] = np.nanmean(q[:, i])
        return p

    def _predict_sim_mean(self, username, similar_users):
        u = self.user_vector(username)
        p = u.copy()
        q = self.utility_matrix.as_matrix()[similar_users]
        s = self.user_sim[self.username_uid_map[username]][similar_users]
        qs = q * s[:, np.newaxis]
        for i, x in enumerate(u):
            if np.isnan(x):
                p[i] = np.nanmean(qs[:, i])
        return p

    def _recs(self, u, p, n_recs, username):
        r = {}
        # u = self._denormalise(u, username)
        # p = self._denormalise(p, username)
        for i, (x, y) in enumerate(zip(u, p)):
            if np.isnan(x) and not np.isnan(y):
                r[self.anime_id_title_map[i]] = y

        sr = sorted(r.items(), key=operator.itemgetter(1), reverse=True)
        return sr[:n_recs]

    def recommend(self, username, n_rec, n_pool, method='mean'):
        u = self.user_vector(username)
        p = self.predict(username, n_rec, n_pool, method)
        r = self._recs(u, p, n_rec, username)
        return r

    def _normalise(self, X):
        self._means = np.nanmean(X, axis=1)
        for i, mu in enumerate(self._means):
            X[i] -= mu
        return X

    def _denormalise(self, p, username):
        return p + self._means[self.username_uid_map[username]]


# TODO: refine, improve.


if __name__ == '__main__':
    cfm = CFMemory()
    # print cfm.utility_matrix

    n_pool = 25

    similar_users = cfm.similar_users('muon', n_pool=n_pool, names=True)
    print '\nsimilar users:'
    for i, user in enumerate(similar_users, start=1):
        print '%s: %s' % (i, user)

    print '\nrecommendations:'
    recs = cfm.recommend('muon', n_rec=20, n_pool=n_pool)
    for i, r in enumerate(recs, start=1):
        print '%s: %s' % (i, r)

    #
    # um = UtilityMatrix()
    #
    # a = um.utility_matrix.as_matrix()
    #
    # a_mean = np.nanmean(a, axis=1)[:, np.newaxis]
    # a_adj = a - a_mean
    # a_adj[np.isnan(a_adj)] = 0
    # s = pairwise_distances(a, metric='cosine')
    # sa = s.dot(a_adj)
    # p = a_mean + sa / np.abs(s).sum(axis=1)[:, np.newaxis]

    # client = MongoClient()
    # db = client.kitsu
    #         # { $where: "this.library.length > 1" }
    # # cursor = db.users.find({ 'name': "muon"})
    # cursor = db.users.find({'$where': 'this.library.length > 100'})
