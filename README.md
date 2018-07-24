# Kitsu API Wrapper and Recommenders
Unofficial Ruby based wrapper for [Kitsu][kitsu] API ([documentation][api]). Various recommender implementations using data obtained from API.

## Current Functionality
**Below sections need to be updated to properly reflect the repository.**


### User Library
Update details after code revision... 
- Store data locally in mongodb.

#### MongoDB Library Item Document
Current fields obtained from Kitsu API. There are more available and could easilty be added.
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

### Media Items
- Get anime by id with associated attributes (majority available).
- Store data locally in mongodb.


### Recommenders
**Note**: python based recommendation code is broken due to re-write of API wrapper, which structures the database differently. I have left them as examples to be revised in the future.

- LSA based recommendations using synopsis: tokenised; stemmed or not; tf-idf; SVD; cosine simliarity.
- Preliminary work on recommender examples using the [Surprise][surprise] library.

- Old work on content based recommender.
- Old work on SVD based collaborative filtering recommender.



[kitsu]: kitsu.io
[api]: https://kitsu.docs.apiary.io/
[surprise]: http://surpriselib.com/
