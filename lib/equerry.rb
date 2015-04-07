require 'elasticsearch'
require 'hashie'

['utils', nil, 'queries', 'filters', 'combinators', 'boosts'].each do |dirname|
  path = if dirname
    File.join(File.expand_path(File.dirname(__FILE__)), 'equerry', dirname, '*.rb')
  else
    File.join(File.expand_path(File.dirname(__FILE__)), 'equerry', '*.rb')
  end
  
  Dir.glob(path).each do |file|
    require file
  end
end

module Equerry
  extend Utils::Configuration

  module Boosts      ; end
  module Queries     ; end
  module Filters     ; end
  module Combinators ; end

  module_function

  # Sets a singleton client for Equerry to use
  #
  # @param [Hash, #options] Options passed to Elasticsearch::Client
  # @return [Elasticsearch::Client] the singleton client
  def client(options = {})
    @logger ||= options[:logger] if options[:logger]
    @client ||= Elasticsearch::Client.new({
      url: ENV['ELASTICSEARCH_URL'],
      log: false,
      adapter: :excon
    }.merge(options))
  end

  def exists?
    client.indices.exists(index: @default_index)
  end

  def drop
    client.indices.delete index: @default_index
  end

  def create
    client.indices.create index: @default_index
  end

  def put_mapping(mapping = {})
    client.indices.put_mapping(
      index: @default_index,
      type:  @default_type,
      body:  mapping
    )
  end

  def refresh
    client.indices.refresh index: @default_index
  end

  def count
    client.cat.count(index: @default_index).split(' ')[2].to_i
  end

  def search(options = {})
    client.search({
      index: @default_index,
      type: @default_type
      }.merge(options)
    )
  end

  def index(body:, id: nil, type: nil)
    type ||= @default_type
    id   ||= body['id'] || body['_id'] || body[:id] || body[:_id]
    
    client.index(index: @default_index, type: type, id: id, body: body)
  end

  def bulk(documents:, type: nil)
    type ||= @default_type
    requests = documents.flat_map do |document|
      id = document['id'] || document['_id'] || document[:id] || document[:_id]
      [
        { index: { '_index' => @default_index, '_type' => type, '_id' => id } },
        document
      ]
    end
    client.bulk body: requests
  end
end
