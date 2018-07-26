require_relative 'helpers'



class LibraryItem < Helpers
  attr_reader :user_id, :record_id, :status, :rating, :media_id, :type

  def initialize user_id, entry_result, media_result
    @user_id = user_id.to_i
    @record_id = entry_result['id'].to_i
    @status = entry_result['attributes']['status']

    rating = entry_result['attributes']['ratingTwenty']
    @rating = rating.nil? ? nil : rating.to_i
    
    @media_id = media_result['data']['id'].to_i
    @type = media_result['data']['type']
  end
end


class Anime < Helpers
  attr_reader :id, :slug, :synopsis, :title, :avg_rating, :rating_freq, :n_users,
    :n_favourites, :start_date, :end_date, :rank_popularity, :rank_rating, :subtype,
    :nsfw; :showtype

  def initialize data
    attributes = data['attributes']
    @id = data['id'].to_i
    @slug = attributes['slug']
    @synopsis = attributes['synopsis']
    @title = attributes['canonicalTitle']
    @avg_rating = attributes['averageRating'].to_f  # TODO: need to handle nil values?
    
    rf_int = {}
    # mongodb needs string keys anyway, so k.to_i redundant...
    attributes['ratingFrequencies'].each_pair { | k, v | rf_int[k.to_i] = v.to_i }
    @rating_freq = rf_int

    @n_users = attributes['userCount'].to_i
    @n_favourites = attributes['favouritesCount'].to_i
    @start_date = attributes['startDate']
    @end_date = attributes['endDate']
    @rank_popularity = attributes['popularityRank'].to_i
    @rank_rating = attributes['ratingRank'].to_i
    @subtype = attributes['subtype']
    @showtype = attributes['showType']
    @nsfw = attributes['nsfw']  # TODO: convert to bool?
  end
end
