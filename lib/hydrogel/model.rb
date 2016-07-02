module Hydrogel
  # This module is needed to be include inside of model class to add basic search methods
  module Model
    def self.included(klass)
      klass.instance_eval do
        extend ::Hydrogel::BasicMethods
        extend ClassMethods
        include ::Hydrogel::Hook
      end
    end

    module ClassMethods
      def h_search(query, options = {})
        search(query.merge(pagination_hash(options)), options)
      end
    end
  end
end
