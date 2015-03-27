require "equerry/version"

module Equerry
  module Boosts ; end
  module Queries ; end
  module Filters ; end

  attr_accessor :index, :logger

  module_function

 # Sets a singleton client for Equerry to use
 #
 # @param [Hash, #options] Options passed to Elasticsearch::Client
 # @return [Elasticsearch::Client] the singleton client
  def client(options = {})
    @logger = options[:logger] if options[:logger]
    @client ||= Elasticsearch::Client.new(options.reverse_merge(
      url: ENV['ELASTICSEARCH_URL'],
      log: false,
      adapter: :excon
    ))
  end

  def refresh
    client.indices.refresh index: @index
  end

  def count
    client.cat.count(index: @index).split(' ')[2].to_i
  end

  def search(options = {})
    client.search(options.reverse_merge(
      index: @index,
      type: @type
    ))
  end

  def index(type:, body:, id: nil)
    id ||= body['id'] || body['_id'] || body[:id] || body[:_id]
    client.index(index: @index, type: type, id: id, body: body)
  end

  def bulk(type:, documents:)
    requests = documents.flat_map do |document|
      id = document['id'] || document['_id'] || document[:id] || document[:_id]
      [
        { index: { '_index' => @index, '_type' => type, '_id' => id } },
        document
      ]
    end
    client.bulk body: requests
  end
end
