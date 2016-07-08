require 'elasticsearch/model'

class Article < ActiveRecord::Base
  include Elasticsearch::Model
  extend Hydrogel::Model

  index_name 'test_index'
  document_type 'article'
end
