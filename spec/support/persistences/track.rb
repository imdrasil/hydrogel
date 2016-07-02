require 'elasticsearch/persistence/model'

class Track
  include Elasticsearch::Persistence::Model
  include Hydrogel::Persistence

  index_name 'test_index'
  document_type 'track'

  attribute :title, String
  attribute :genre, String
  attribute :song_uri, String
  attribute :item_number, Integer
end
