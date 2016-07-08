require "hydrogel/version"
require 'hydrogel/config'
require 'hydrogel/basic_methods'

require 'hydrogel/curl'
require 'hydrogel/request_builder'
require 'hydrogel/query'
require 'hydrogel/model'

module Hydrogel
  extend BasicMethods

  def h_search(query, options = {})
    hash = { body: query.reverse_merge(pagination_hash(options)) }
    hash.merge!(options.slice(:index, :type))
    res = client.search(hash)
    extract_result(res, options[:extract])
  end

  private

  def client
    @client ||= if defined?(Elasticsearch::Model) && Elasticsearch::Model.client
                  Elasticsearch::Model.client
                else
                  Elasticsearch::Persistence.client
                end
  end

  def extract_result(response, type)
    case type
      when :hits
        response['hits']['hits']
      when :source, :sources
        response['hits']['hits'].map { |e| e['_source'] }
      when :fields
        response['hits']['hits'].map { |e| e['fields'] }
      else
        response
    end
  end

  (BasicMethods::ALL_METHODS + [:h_search, :client, :extract_result]).each { |method| module_function method }
end
