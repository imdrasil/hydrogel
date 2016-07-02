require 'elasticsearch/model'
require 'elasticsearch/persistence/model'

require "hydrogel/version"
require 'hydrogel/config'
require 'hydrogel/basic_methods'

require 'hydrogel/curl'
require 'hydrogel/hook'
require 'hydrogel/request_builder'
require 'hydrogel/query'
require 'hydrogel/model'
require 'hydrogel/persistence'

module Hydrogel
  include BasicMethods

  def h_search(query, options = {})
    hash = { body: query.reverse_merge(pagination_hash(options)) }
    hash.merge!(options.slice(:index, :type))
    res = client.h_search(hash)
    extract_result(res, options[:extract])
  end

  (BasicMethods::METHODS + [:h_search]).each { |method| module_function method }

  private

  def client
    Elasticsearch::Persistence.client
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
end
