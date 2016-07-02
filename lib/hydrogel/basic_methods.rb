module Hydrogel
  module BasicMethods
    PAGINATION_OPTIONS = [:page, :per, :per_page]
    METHODS = [:filter, :query, :function_score]

    def filter(filters, options = {})
      h_search({ filter: filters }, options)
    end

    def query(query, options = {})
      search({ query: query }, options)
    end

    def function_score(query, functions, options = {})
      query[:query] = function_score_hash(functions, query)
      search(query, options)
    end

    private

    def pagination_hash(options)
      return {} unless PAGINATION_OPTIONS.any? { |o| options.key?(o) }
      page = (options.delete(:page) || 1).to_i
      per_page = (options.delete(:per_page) || options.delete(:per) || Config.per_page).to_i
      { from: (page - 1) * per_page, size: per_page }
    end

    def function_score_hash(functions, options)
      { function_score: functions.merge(options.slice(:query)) }
    end
  end
end
