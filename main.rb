require_relative 'kitsu'
require_relative 'db'

require 'mongo'


Mongo::Logger.logger.level = Logger::WARN



# class Database
#   attr_reader :client, :host, 

#   def initialize db_name: 'test', host: ['127.0.0.1:27017']
#     @host = host
#     @db_name = db_name
#     @client = Mongo::Client.new(host, {database: db_name})
#   end
# end


class ETL < Database
  attr_reader :kitsu, :client

  def initialize db_name: 'kitsu', host: ['127.0.0.1:27017']
    @kitsu = Kitsu.new()
    @client = Mongo::Client.new(host, {database: db_name})
  end

  def insert_many_docs collection_name, docs
    begin
      puts "inserting..."
      result = @client[collection_name].insert_many(docs)
      puts "records inserted: #{result.inserted_count}"
    rescue StandardError => e
      puts "error: #{e}"
    end
    puts "complete.\n"
  end
  
  
  def get_libraries user_ids
    docs = @kitsu.batch_get_libraries_docs(user_ids)
    insert_many_docs('library', docs)
  end
  
  
  def get_anime media_ids
    docs = @kitsu.get_anime_documents(media_ids)
    insert_many_docs('anime', docs)
  end

end



etl = ETL.new()
# etl.get_anime(1..10)
etl.get_libraries(1003..1500)