require 'oauth'
require 'json'
require 'addressable/uri'



class Helpers
  def to_hash
    hash = {}
    instance_variables.each {|x| hash[x.to_s.delete("@")] = instance_variable_get(x) }
    hash
  end
end


class Configuration
  attr_reader :root, :consumer

  def initialize
    # kitsu has not yet implemented application registration the following 
    # key/secret pair are public and available on the API documentation site:
    # https://kitsu.docs.apiary.io/#reference/authentication
    
    key = "dd031b32d2f56c990b1425efe6c42ad847e7fe3ab46bf1299f05ecd856bdb7dd"
    secret = "54d7307928f63414defd96399fc31ba847961ceaecef3a5fd93144e960c0e151"
    @root = "https://kitsu.io/api/edge/"
    @consumer = OAuth::Consumer.new(key, secret)
  end
end


class User < Helpers
  attr_reader :id, :name, :about, :n_ratings

  def initialize data
    @id = data['id']
    @name = data['attributes']['name']
    @about = data['attributes']['about']
    @n_ratings = data['attributes']['ratingsCount']
  end
  
end


class LibraryEntry < Helpers
  attr_reader :id, :created, :updated, :started, :finished, :status, :rating

  def initialize item
    @id = item['id']
    @created = item['attributes']['createdAt']
    @updated = item['attributes']['updatedAt']
    @started = item['attributes']['startedAt']
    @finished = item['attributes']['finishedAt']
    @status = item['attributes']['status']
    @rating = item['attributes']['ratingTwenty']
  end

end


class KitsuAPI < Configuration

  def initialize
    super()
  end

  def get_result url
    response = @consumer.request(:get, url)
    return JSON.parse(response.body)
  end

  def get_user_by_name name
    # TODO: can return multiple users with same name...
    uri = Addressable::URI.parse("#{@root}users")
    uri.query_values = {"filter[name]" => name}
    result = self.get_result(uri.to_s)
    return User.new(result['data'][0])
  end

  def get_user_by_id id
    uri = Addressable::URI.parse("#{@root}users/#{id}")
    result = self.get_result(uri.to_s)

    unless result.key?('errors')
      return User.new(result['data'])
    else
      return nil
    end

  end

  def get_user_library id, type, status, limit=500
    """
    id: user id
    type: media type - Anime; Manga --> case sensitive
    status: complete, watching, planned, hold, dropped
    limit: number of results to return per page - max 500

    returns: list of LibraryEntry objects
    """

    # initial parameters
    uri = Addressable::URI.parse("#{@root}library-entries")

    uri_query = {
      "filter[user_id]" => id,
      "filter[media_type]" => type,  # 
      "filter[status]" => status,
      "page[limit]" => limit
    }
    
    uri.query_values = uri_query

    result = self.get_result(uri.to_s)
    entries = self._get_entries(result)

    # get all results from subsquent pages as paginated response
    while result['links'].key?('next')
      result = self.get_result(result['links']['next'])
      entries += self._get_entries(result)
    end

    return entries
  end

  def _get_entries result
    """
    input: library-entries query result
    return: list of LibraryEntry objects
    """
    entries = []
    result['data'].each do |item|
      entries << LibraryEntry.new(item)
    end
    return entries
  end

  def get_user_library_document id
    user = self.get_user_by_id(id)

    unless user.nil?
      entries = self.get_user_library(id, 'Anime', 'completed', 500)
    
      doc = {
        user: user.to_hash,
        library: []
      }
    
      entries.each do |x|
        doc[:library] << x.to_hash
      end

      return doc
    else
      return nil
    end
  end

end