require 'elasticsearch/persistence/model'

class Track
  include Elasticsearch::Persistence::Model
  extend Hydrogel::Model

  index_name 'test_index'
  document_type 'track'

  attribute :title, String
  attribute :genre, Integer
  attribute :song_uri, String
  attribute :item_number, Integer
end
