module Hydrogel
  module BasicMethods
    PAGINATION_OPTIONS = [:page, :per, :per_page]
    ONE_ARG_METHODS = [:query, :filter, :size, :from, :filtered, :fields, :no_fields, :facets, :index, :type,
                       :aggs, :pluck, :sort_by, :order]
    TWO_ARGS_METHODS = [:terms, :term, :ids, :match, :function_score, :common, :prefix, :wildcard, :regexp, :fuzzy]
    NO_ARG_METHODS = [:many]
    ALL_METHODS = ONE_ARG_METHODS + TWO_ARGS_METHODS + NO_ARG_METHODS + [:multi_match]

    def self.extended(klass)
      klass.instance_eval do
        ALL_METHODS.each do |method|
          define_method(method) do |*args|
            ::Hydrogel::Query.new(self).send(method, *args)
          end
        end
      end
    end

    private

    def pagination_hash(options)
      return {} unless PAGINATION_OPTIONS.any? { |o| options.key?(o) }
      page = (options.delete(:page) || 1).to_i
      per_page = (options.delete(:per_page) || options.delete(:per) || Config.per_page).to_i
      { from: (page - 1) * per_page, size: per_page }
    end
  end
end
