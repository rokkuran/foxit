require 'oauth'
require 'json'
require 'mongo'
require 'addressable/uri'

require_relative 'db'


# kitsu.io api authentication details
$api = "https://kitsu.io/api/edge/"
consumer_key = "xxxxxxxxxxxxxxxxxxxxxxx"
consumer_secret = "xxxxxxxxxxxxxxxxxxxx"
$consumer = OAuth::Consumer.new(consumer_key, consumer_secret)


class User
  def initialize(id, limit=2500, status=['completed'])
    @id = id
    @limit = limit

    @status = {
      'watching' => 1,
      'planned' => 2,
      'completed' => 3,
      'hold' => 4,
      'dropped' => 5
    }

    @uri_query = [
      ["filter[user_id]", id],
      ['filter[media_type]', 'Anime'],
      ['filter[status]', status.map { |x| @status[x] }.join(",")],
      ['include', 'user,media'],
      ['fields[user]', 'name'],
      ['fields[anime]', 'id,canonicalTitle'],
      ['page[limit]', @limit]]

    uri = Addressable::URI.parse("#{$api}/library-entries")
    uri.query_values = @uri_query
    @uri_library = uri.to_s
  end

  def name
    @name
  end

  def details
    puts "user_id: #{@id}\nuri_library: #{@uri_library}"
  end

  def get_library
    response = $consumer.request(:get, @uri_library)
    return JSON.parse(response.body)
  end

  def get_library_entries(verbose=false)
    if verbose
      puts "\nretreiving library items..."
    end
    lib = get_library()

    unless lib['data'].nil? | lib['included'].nil?
      anime_id_rating = {}
      lib['data'].each do |item|
        rating = item['attributes']['rating'].to_f
        id = item['relationships']['media']['data']['id'].to_i
        anime_id_rating[id] = rating
      end

      anime_id_title = {}
      lib['included'].each do |item|
        type = item['type']
        if type == 'users'
          @name = item['attributes']['name']
        elsif type == 'anime'
          id = item['id'].to_i
          title = item['attributes']['canonicalTitle']
          anime_id_title[id] = title
        end
      end

      records = []
      anime_id_title.each_pair do |id, title|
        record = {
          'anime_id' => id,
          'rating' => anime_id_rating[id],
          'title' => title
        }
        records << record
      end
    end

    if verbose
      puts "library retrieved.\n"
    end

    return records
  end

end


def batch_user_libs(id_start, id_end)
  libs = []
  (id_start..id_end).each_with_index do |user_id, i|
    user = User.new(user_id)
    lib = user.get_library_entries
    unless lib.nil?
      puts "#{i}: user_id=#{user_id}; lib_size=#{lib.size}"
      record = {:user_id => user_id, :name => user.name, :library => lib}
      libs << record
    end
  end
  return libs
end


def populate_users(id_start, id_end)
  libs = batch_user_libs(id_start, id_end)
  users = Collection.new('users')
  users.insert(libs)
end
