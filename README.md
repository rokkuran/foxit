# Kitsu API Wrapper
Unofficial Ruby wrapper for [Kitsu][kitsu] API ([documentation][api]).

Note: this is the initial version and was written primarily to store data locally on which to train recommendation models. Hence, it works well for the task it was created but there are a few gaps that could be included without too much effort. 


## Installation
```
gem install foxit
```

## Usage
A few quick examples are detailed below:

### Retrieving Data
Get an anime item by id. 
```ruby
api = Foxit::API.new()
result = api.get_anime_by_id(1)
```

This returns the full json response; however, an object based result can be returned as per the following (planned to be returned as default)
```ruby
item = Anime.new(result['data'])
```

Similarly, getting a users library. This returns a list of entries from the `'data'` attribute of the json returned. 
```ruby
result = api.get_library_by_id(1)
```


### Storing Data with MongoDB
If you don't have mongodb installed you can download the free community version from [here][mongodb]. Once installed, you need to start the service via terminal:
```
mongod --port 27017 --dbpath /path/to/db
```
Note: you can stop it by pressing `ctrl+c` when the terminal is active or by using
```
mongod --dbpath /path/to/db --shutdown
```

Once you have mongodb running you can retreive and store data by using the following functions.

**Please use responsibly!** Library results are especially expensive as they require a secondary call to lookup the media_id from the library item id that is returned in the user library request. In other words, for the benefit of everyone, don't punish the API with hundreds of calls.

```ruby
etl = Foxit::ETL.new()
etl.get_anime(1..100)  # stores anime item results from media_id 1 to 100
etl.get_libraries(1..25)  # stores user library results from user_id 1 to 25
```

#### MongoDB Library Item
Current fields obtained from Kitsu API. There are more available and could easilty be added; however, this was all I needed for working on the recommendation models.
```
{
  '_id': ObjectId('5b56ad7dafd2a496c0faa495'),
  'media_id': 1376,       # id for anime, e.g., this one relates to 'Code Geass: Lelouch of the Rebellion'
  'rating': 17,           # user rating [1-20]; None if not rated.
  'record_id': 18344699,  # library item id; used to return the actual media_id
  'status': 'completed',  # media viewing status: {completed, planned, watching, hold, dropped}
  'type': 'anime',        # media type: {Anime, Manga, Drama?}.
  'user_id': 1            # user id
}
```


#### MongoDB Anime Item

```
{ 
  '_id': ObjectId('5b570e4eafd2a41db810927b'),
  'avg_rating': 84.36,
  'end_date': '1999-04-24',
  'id': 1,
  'n_favourites': 0,
  'n_users': 71919,
  'nsfw': False,
  'rank_popularity': 15,
  'rank_rating': 27,
  'rating_freq': { '10': 415,
                   '11': 27,
                   '12': 1700,
                   '13': 53,
                   '14': 3878,
                   '15': 139,
                   '16': 5255,
                   '17': 255,
                   '18': 6261,
                   '19': 238,
                   '2': 1566,
                   '20': 20974,
                   '3': 33,
                   '4': 351,
                   '5': 15,
                   '6': 115,
                   '7': 16,
                   '8': 1545,
                   '9': 22},
  'showtype': 'TV',
  'slug': 'cowboy-bebop',
  'start_date': '1998-04-03',
  'subtype': 'TV',
  'synopsis': 'In the year 2071, humanity has colonized several of the planets '
              'and moons of the solar system leaving the now uninhabitable '
              'surface of planet Earth behind. The Inter Solar System Police '
              'attempts to keep peace in the galaxy, aided in part by outlaw '
              'bounty hunters, referred to as "Cowboys". The ragtag team '
              'aboard the spaceship Bebop are two such individuals.\r\n'
              'Mellow and carefree Spike Spiegel is balanced by his '
              'boisterous, pragmatic partner Jet Black as the pair makes a '
              'living chasing bounties and collecting rewards. Thrown off '
              'course by the addition of new members that they meet in their '
              'travels�Ein, a genetically engineered, highly intelligent Welsh '
              'Corgi; femme fatale Faye Valentine, an enigmatic trickster with '
              'memory loss; and the strange computer whiz kid Edward Wong�the '
              "crew embarks on thrilling adventures that unravel each member's "
              'dark and mysterious past little by little. \r\n'
              'Well-balanced with high density action and light-hearted '
              'comedy, Cowboy Bebop is a space Western classic and an homage '
              'to the smooth and improvised music it is named after.  \r\n'
              '[Written by MAL Rewrite]',
  'title': 'Cowboy Bebop'
}
```


## Further Work
- Add some more detail/examples to README
- Extend on functionality/usability for benefit of other users.



[kitsu]: kitsu.io
[api]: https://kitsu.docs.apiary.io/
[mongodb]: https://www.mongodb.com/download-center#community
