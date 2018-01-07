require_relative 'user'
require_relative 'anime'
require_relative 'db'

#********************** USER RELATED ***********************

# user = User.new(52345)  # 6 items all nil ratings
# user = User.new(52348)  # 160+ items
# user = User.new(52349)  # 2 items
# user = User.new(52350)  # 122 items
# user = User.new(1)  # 222 items
# user = User.new(2)  # 244 itBems
# user = User.new(8)  # 1700+ items
# user = User.new(4016)  # muon
# lib = user.get_library
# puts JSON.pretty_generate(lib)

populate_users(901, 1000)

# # query = {'name' => 'muon'}
# # query = {'library.rating' => {'$lte': 0}}
# # query = {'user_id' => {'$gt': 95}}
# # query = {'library.rating' => {'$gte': 4}}
# # query = {'library' => {'$elemMatch' => {'title' => 'Cowboy Bebop'}}}
# query = {'user_id' => 4016}
# query = {}
# users = Collection.new('users')
# # puts users.query(query)
# users.count(query)


#********************** ANIME RELATED **********************
# puts get_doc('anime', 165)
# puts get_genres('anime', 1)
# docs = get_media('anime', 1, 50)
# docs = get_media('anime', 51, 52)
# docs = get_media('anime', 53, 150)
# docs = get_media('anime', 151, 151)
# docs = get_media('anime', 152, 250)
# docs = get_media('anime', 251, 500)
# docs = get_media('anime', 501, 1000)
# docs = get_media('anime', 1001, 2000)


# update_db(docs, 'anime')
# query_db('anime')


# query = {'id' => {'$gt': 49}}
# query = {'id' => 1000}
# query = {'slug' => 'cowboy-bebop'}
# query = {'averageRating' => {'$gt' => 4.4}}
# query = {
#   'averageRating' => {'$gt' => 4.2},
#   'genres' => {'$in' => [4]},
#   'genres' => {'$in' => [20]}
# }

# anime = Collection.new('anime')
# query = {}
# puts anime.query(query)
# anime.count(query)
