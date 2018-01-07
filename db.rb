require 'json'
require 'mongo'


# mongodb config
Mongo::Logger.logger.level = Logger::WARN
$client_host = ['127.0.0.1:27017']
$client_options = {database: 'kitsu'}


class Collection
  def initialize(name)
    @name = name
    client = Mongo::Client.new($client_host, $client_options)
    @collection = client[name]
  end

  def pretty_print(cursor)
    puts JSON.pretty_generate(cursor.to_a)
  end

  def query(q)
    cursor = @collection.find(q)
    # pretty_print(cursor)
    return cursor.to_a
  end

  def delete_all
    @collection.delete_many({})
    puts "all records deleted from '#{@name}' collection."
  end

  def insert(docs)
    begin
      puts "\ninserting records in '#{@name}'..."
      result = @collection.insert_many(docs)
      puts "records inserted: #{result.inserted_count}"
    rescue StandardError => e
      puts "error: #{e}"
    end
    puts "insertion complete.\n"
  end

  def count(q)
    result = query(q).count()
    puts "query count = #{result}"
    return result
  end
end
