module Hydrogel
  module Hook
    def self.included(klass)
      klass.instance_eval do
        extend ClassMethods

        class << self
          attr_accessor :_es_per_page

          def default_page_size
            @_es_per_page
          end
        end

        def es_per_page(value)
          self.class._es_per_page = value
        end
      end
    end

    module ClassMethods
      ONE_ARG_METHODS = [:query, :filter, :size, :from, :filtered, :fields, :no_fields, :facets, :index, :type,
                         :aggs, :pluck, :sort_by, :order]
      TWO_ARGS_METHODS = [:terms, :term, :ids, :match, :function_score]
      NO_ARG_METHODS = [:many]
      ALL_METHODS = ONE_ARG_METHODS + TWO_ARGS_METHODS + NO_ARG_METHODS + [:multi_match]

      ALL_METHODS.each do |method|
        define_method(method) do |*args|
          ::Hydrogel::Query.new(self).send(method, *args)
        end
      end
    end
  end
end
