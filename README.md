# Kitsu API Wrapper
Ruby based wrapper for [Kitsu][kitsu] API ([documentation][api]). 

## Current Functionality

### User
- Get user by id or name with associated attributes (minimal selection currently).
- Get all user library entries with id, rating, timings.
- Store data locally in mongodb - chunked batch requests implemented.

### Items
- Get anime by id with associated attributes (majority available)
- Store data locally in mongodb - chunked batch requests implemented.


### Recommenders
**Note**: python based recommendation code is broken due to re-write of API wrapper, which structure the database differently. I have left them as examples to be revised in the future.

- Preliminary work on content based recommender.
- Preliminary work on SVD based collaborative filtering recommender.


[kitsu]: kitsu.io
[api]: https://kitsu.docs.apiary.io/
