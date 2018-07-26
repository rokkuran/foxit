require_relative 'objects'

require 'net/http'
require 'json'
require 'addressable/uri'


module Foxit

  class API

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
  
  
    def get_media_relationship_by_id entry_id
      # adding memoisation to stop requesting same media docs
      # TODO: extend to items already existing in db?
      @get_media_relationship_by_id ||= {}
      return @get_media_relationship_by_id[entry_id] if @get_media_relationship_by_id.key?(entry_id)
  
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
  
    # TODO: should probably assign to a @variable
    def batch_get_libraries user_ids, max_threads=200
  
      all_library_entries = []
      user_libraries = self.batch_get_results(user_ids, :get_library_by_id, max_threads)
    
      user_libraries.each do |user_id, library|
    
        media_ids = []
        library.map { |entry| media_ids << entry['id'] }
        media_results = self.batch_get_results(media_ids, :get_media_relationship_by_id, max_threads)
        
        library.each do |entry|
          all_library_entries << LibraryItem.new(user_id, entry, media_results[entry['id']])
        end
    
      end
    
      all_library_entries
    end
  
    
    def get_user_library
      # TODO: return user library using single id call to batch_get_library
    end
    
  
    def batch_get_libraries_docs user_ids, max_threads=200
      all_library_entries = self.batch_get_libraries(user_ids, max_threads)
      
      docs = []
      all_library_entries.map { |entry| docs << entry.to_hash }
  
      docs
    end
  
  
    def build_anime_url id
      "#{@root}/anime/#{id}"
    end
  
  
    def get_anime_by_id id
      url = build_anime_url(id)
      self.get_result(url)
    end
  
  
    def batch_get_anime anime_ids, max_threads=200
      results = self.batch_get_results(anime_ids, :get_anime_by_id, max_threads)
  
      anime_items = []
      results.each do |id, result|
        unless result.key?('errors')
          anime_items << Anime.new(result['data'])
        end
      end
  
      anime_items
    end
  
    def get_anime_documents anime_ids, max_threads=200
      anime_items = self.batch_get_anime(anime_ids, max_threads)
      self.objects_to_hash(anime_items)
    end
  
  end

end
