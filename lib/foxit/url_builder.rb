require 'addressable/uri'



class URLBuilder

  attr_reader :root

  def initialize
    @root = "https://kitsu.io/api/edge/"
  end


  def media entry_id
    "#{@root}/library-entries/#{entry_id}/relationships/media"
  end


  def library id, type='Anime', status='completed', limit=500
    uri = Addressable::URI.parse("#{@root}library-entries")

    uri_query = {
      "filter[user_id]" => id,
      "filter[media_type]" => type,
      "filter[status]" => status,
      "page[limit]" => limit
    }
    uri.query_values = uri_query
    
    uri.to_s
  end

  
  def anime_by_id id
    "#{@root}/anime/#{id}"
  end


  def anime_by_slug slug
    "#{@root}/anime?filter[slug]=#{slug}"
  end

end