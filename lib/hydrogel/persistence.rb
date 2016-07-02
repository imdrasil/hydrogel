module Hydrogel
  module Persistence
    def self.included(klass)
      klass.instance_eval do
        extend BasicMethods
        extend ClassMethods
        include Hook
      end
    end

    module ClassMethods
      def h_search(query, options = {})
        self.search(query.merge(pagination_hash(options)), options)
      end
    end
  end
end
