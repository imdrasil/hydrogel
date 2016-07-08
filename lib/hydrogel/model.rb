module Hydrogel
  # This module is needed to be include inside of model class
  module Model
    extend ::Hydrogel::BasicMethods
    def self.extended(klass)
      klass.instance_eval do
        extend ::Hydrogel::BasicMethods
      end
    end

    def h_search(query, options = {})
      search(query.merge(pagination_hash(options)), options)
    end

    def h_scope(name, body)
      singleton_class.send(:define_method, name, body)
      Query.add_scope(self, name, body)
    end

    def h_default_scope(body)
      Query.add_default_scope(self, body)
    end

    def h_unscoped
      Query.new(self, uscoped: true)
    end
  end
end
