require 'net/http'
require 'json'
require 'addressable/uri'


class Helpers
  def to_hash
    hash = {}
    instance_variables.each {|x| hash[x.to_s.delete("@")] = instance_variable_get(x)}
    hash
  end
end


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


class Kitsu

  def initialize
    @root = "https://kitsu.io/api/edge/"
  end


  def build_library_url id, type='Anime', status='completed', limit=500
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

  
  def build_media_url entry_id
    "#{@root}/library-entries/#{entry_id}/relationships/media"
  end


  def get_result url
    response = Net::HTTP.get(URI.parse(url))
    JSON.parse(response)
  end
  

  def get_library_by_url url, entries=[]

    result = self.get_result(url)
    entries += result['data']
  
    if result['links'].key?('next')
      # recursion to retrieve additional results that have ben paginated
      result = self.get_library_by_url(result['links']['next'], entries)
    else
      return entries
    end
  end


  def get_library_by_id user_id
    url = self.build_library_url(user_id)
    self.get_library_by_url(url)
  end


  def get_media_by_id entry_id
    url = self.build_media_url(entry_id)
    self.get_result(url)
  end


  def batch_get_results ids, fn, max_threads
    """
    ids: ids of results returned: user_id | library_entry_id in this case.
    fn: function name to use to return results (need to use symbol method name)
        e.g. :get_result
    max_threads: maximum number of active threads.
    """

    results = {}
    threads = []

    ids.each do |id|

      if Thread.list.count % max_threads != 0
        thread = Thread.new do
          # adding lock slows down considerably shouldn't matter as results are written to hash?
          results[id] = send(fn, id)
        end
        threads << thread
      else
        # wait for open threads to finish before starting new one
        threads.each(&:join)

        thread = Thread.new do
          results[id] = send(fn, id)
        end
        threads << thread
      end

    end

    threads.each(&:join)

    results
  end


  def get_batch_libraries user_ids, max_threads=200

    all_library_entries = []
    user_libraries = self.batch_get_results(user_ids, :get_library_by_id, max_threads)
  
    user_libraries.each do |user_id, library|
  
      media_ids = []
      library.map { |entry| media_ids << entry['id'] }
      media_results = self.batch_get_results(media_ids, :get_media_by_id, max_threads)
      
      library.each do |entry|
        all_library_entries << LibraryItem.new(user_id, entry, media_results[entry['id']])
      end
  
    end
  
    all_library_entries
  end
  

  def get_batch_libraries_docs user_ids, max_threads=200
    all_library_entries = self.get_batch_libraries(user_ids, max_threads)
    
    docs = []
    all_library_entries.map { |entry| docs << entry.to_hash }

    docs
  end


end



def main

  kitsu = Kitsu.new()
  all_library_entries = kitsu.get_batch_libraries(1..10)

  all_library_entries.each_with_index do |entry, i|
    if i < 100
      p "user_id=#{entry.user_id}; entry_id=#{entry.record_id}; media_id=#{entry.media_id}, rating=#{entry.rating}"
    else
      break
    end
  end

end



# main()