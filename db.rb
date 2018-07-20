require 'mongo'


Mongo::Logger.logger.level = Logger::WARN


class Database
  attr_reader :client_host, :client_options, :client

  def initialize host: ['127.0.0.1:27017'], name: 'test'
    client_host = host
    client_options = {database: name}
    @client = Mongo::Client.new(client_host, client_options)
  end

  def collection name
    return @client[name]
  end

end