import pymongo
from pymongo import MongoClient

import pandas as pd

import json
import pprint
pp = pprint.PrettyPrinter(indent=2)



def db_collections(client: MongoClient):
	d = {db: [collection for collection in client[db].list_collection_names()] for db in client.list_database_names()}
	return json.dumps(d)


def encode_dict(d: dict, encoding='utf-8'):
	a = {k: v.encode(encoding) for k, v in d.items() if type(v)==str}
	b = {k: v for k, v in d.items() if type(v)!=str}
	return {**a, **b}


def get_item_data(client: MongoClient):
	collection = client.kitsu.anime
	print("n_items: {}".format(collection.count()))

	attributes = ['id', 'avg_rating']
	data = {k: [] for k in attributes}

	for i, doc in enumerate(collection.find()):
		x = encode_dict(doc)
		for k in data:
			data[k].append(x[k])
	
	return pd.DataFrame(data)



if __name__ in "__main__":
	client = MongoClient()
	print(db_collections(client))

	# df = get_item_data(client)
	# print(df)

	# collection = client.test.anime
	# collection = client.test.users
	# collection = client.test.library
	# collection = client.kitsu.library
	collection = client.kitsu.anime
	# collection = client.kitsu.users

	print("n_docs: {}".format(collection.count()))
	# pp.pprint(collection.find_one())

	# get max anime id
	doc = collection.find_one(sort=[("id", -1)])
	pp.pprint(doc)

	# # # get max user_id
	# doc = collection.find_one(sort=[("user_id", -1)])
	# pp.pprint(doc)

	# distinct_ratings = collection.find().distinct('rating')
	# print(distinct_ratings)

	# cursor = collection.find({'user_id': {'$max': 5000}})
	# for i, doc in enumerate(cursor):
	# 	pp.pprint(doc)
	# 	print(doc)

	# cursor = collection.find(
	# 	{'user_id': 2},
	# 	{'user_id': 1, 'media_id': 1, 'rating': 1, '_id': 0}
	# )

	# for i, doc in enumerate(cursor):
	# 	print(doc)

	# collection.remove({})
	# print(collection.count())
