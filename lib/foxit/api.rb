require_relative 'objects'
require_relative 'helpers'
require_relative 'url_builder'

require 'net/http'
require 'json'



module Foxit

  # TODO: probably split out library and anime methods
  class API < Helpers

    attr_reader :urlbuilder
    attr_accessor :max_threads

    def initialize max_threads=200
      @max_threads = max_threads
      @urlbuilder = URLBuilder.new()
    end
  
  
    def get_result url
      response = Net::HTTP.get(URI.parse(url))
      JSON.parse(response)
    end
    
  
    def _get_library_by_url url, entries=[]
  
      result = self.get_result(url)
      entries += result['data']
    
      if result['links'].key?('next')
        # recursion to retrieve additional results that have ben paginated
        result = self._get_library_by_url(result['links']['next'], entries)
      else
        return entries
      end
    end
  
  
    def get_library_by_id user_id
      url = @urlbuilder.library(user_id)
      self._get_library_by_url(url)
    end
  
  
    def get_media_relationship_by_id entry_id
      # adding memoisation to stop requesting same media docs
      # TODO: extend to items already existing in db?
      @get_media_relationship_by_id ||= {}
      return @get_media_relationship_by_id[entry_id] if @get_media_relationship_by_id.key?(entry_id)
  
      url = @urlbuilder.media(entry_id)
      self.get_result(url)
    end
  
  
    def batch_get_results ids, fn
      """
      ids: ids of results returned: user_id | library_entry_id in this case.
      fn: function name to use to return results (need to use symbol method name)
          e.g. :get_result
      """
  
      results = {}
      threads = []
  
      ids.each do |id|
  
        if Thread.list.count % @max_threads != 0
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
  

    def batch_get_libraries user_ids
  
      all_library_entries = []
      user_libraries = self.batch_get_results(user_ids, :get_library_by_id)
    
      user_libraries.each do |user_id, library|
        all_library_entries += self._create_library_items(user_id, library)
      end
    
      all_library_entries
    end


    def _create_library_items user_id, library

      # get media_ids from record_ids (not in same response, additional request required)
      record_ids = []
      library.map { |entry| record_ids << entry['id'] }
      media_results = self.batch_get_results(record_ids, :get_media_relationship_by_id)
      
      library_entries = []
      library.each do |entry|
        library_entries << LibraryItem.new(user_id, entry, media_results[entry['id']])
      end

      library_entries
    end

    
    def get_user_library_by_id user_id
      library = self.get_library_by_id(user_id)
      self._create_library_items(user_id, library)
    end
    
  
    def batch_get_libraries_docs user_ids
      all_library_entries = self.batch_get_libraries(user_ids)
      
      docs = []
      all_library_entries.map { |entry| docs << entry.to_hash }
  
      docs
    end


    def _get_anime_by_attr filter_attr, filter_value, rtype=:object

      # TODO: this is a bit of a mess

      case filter_attr
      when :id
        url = @urlbuilder.anime_by_id(filter_value)
      when :slug
        url = @urlbuilder.anime_by_slug(filter_value)
      else
        raise ArgumentError.new("filter_attr argument (1st) not in {:id, :slug}")
      end

      result = self.get_result(url)

      case rtype
      when :json
        return result
      when :object
        case filter_attr
        when :id
          return Anime.new(result['data'])
        when :slug
          # filtering by slug results in the 'data' attribute to be an array
          return Anime.new(result['data'][0])
        end
      else
        raise ArgumentError.new("rtype not :object or :json")
      end
    end


    def get_anime_by_id id, rtype=:object
      self._get_anime_by_attr(:id, id, rtype)
    end


    def get_anime_by_slug slug, rtype=:object
      self._get_anime_by_attr(:slug, slug, rtype)
    end


    def _get_anime_by_id_json id
      self._get_anime_by_attr(:id, id, :json)
    end


    def batch_get_anime anime_ids
      results = self.batch_get_results(anime_ids, :_get_anime_by_id_json)
  
      anime_items = []
      results.each do |id, result|
        unless result.key?('errors')
          anime_items << Anime.new(result['data'])
        end
      end
  
      anime_items
    end
  

    def get_anime_documents anime_ids
      anime_items = self.batch_get_anime(anime_ids)
      self.objects_to_hash(anime_items)
    end
  
  end

end
