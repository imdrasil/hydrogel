require 'hydrogel/query'

module Hydrogel
  class RequestBuilder
    def initialize(query)
      @query = query
    end

    (Query::ATTRS + Query::ANOTHER_ATTRS).each do |var|
      define_method(var) do
        @query.instance_variable_get("@#{var}")
      end
    end

    def build(options = {})
      [build_hash, additional_get_attrs(options)]
    end

    private

    def additional_get_attrs(options)
      options[:index] = index if index
      options[:type] = type if type
      options
    end

    def build_hash
      hash = initialize_query
      build_query_part(hash)
      hash[:filter] = build_matchers_hash(filter) unless filter.empty?
      hash[:fields] = fields if !fields.empty? || no_fields
      add_pagination(hash)
      add_aggs(hash)
      add_sort(hash)
      add_functions(hash)
      hash
    end

    def build_query_part(hash)
      query_part = if multi_match
                     { multi_match: multi_match }
                   elsif query.present?
                     build_matchers_hash(query, :bool)
                   end
      add_filtered_filter(hash)
      add_query_part_to_hash(query_part, hash)
    end

    def add_functions(hash)
      return if functions.empty?
      hash[:query][:function_score][:functions] = functions
      hash[:query][:function_score][:score_mode] = score_mode if score_mode
    end

    def add_filtered_filter(hash)
      return if filtered.empty?
      filtered_part = if hash[:query][:function_score]
                        hash[:query][:function_score][:query][:filtered]
                      else
                        hash[:query][:filtered]
                      end
      filtered_part[:filter] = build_matchers_hash(filtered)
    end

    def add_sort(hash)
      return if sort.empty?
      hash[:sort] = sort
    end

    def add_aggs(hash)
      if aggs.present?
        hash[:aggs] = aggs
      elsif facets.present?
        hash[:facets] = facets
      end
    end

    def add_pagination(hash)
      if from || size
        hash[:size] = size if size
        hash[:from] = from if from
      elsif page
        hash[:size] = per_page || Config.per_page
        hash[:from] = page * hash[:size]
      end
    end

    def build_matcher_hash(type, var)
      filter = {}
      operators_by_type(type).each do |operator|
        values = var.select { |e| e[:operator] == operator }.map { |e| reject_operator(e) }
        next if values.empty?
        matchers_conversions(values)
        filter[operator] = values
      end
      filter
    end

    def matchers_conversions(matchers)
      parse_common(matchers)
      matchers
    end

    def parse_common(array)
      array.select { |hash| hash[:common] }.each do |hash|
        hash[:common] = { body: hash[:common] } unless hash[:common][:body]
      end
    end

    def operators_by_type(type)
      case type
      when :root
        Query::ROOT_OPS
      when :bool
        Query::BOOL_OPS
      else
        []
      end
    end

    def add_query_part_to_hash(query, hash)
      query_part = hash[:query][:function_score] || hash
      if query_part[:query][:filtered]
        query_part[:query][:filtered][:query] = query || { match_all: {} }
      else
        query_part[:query] = query || { match_all: {} }
      end
    end

    def build_matchers_hash(var, types = [:root, :bool])
      types = [types] unless types.is_a?(Array)
      if var.size > 1 || var.first[:operator] && var.first[:operator] != default_operator(types)
        add_default_operator(var, types)
        if types.include?(:bool)
          { bool: build_matcher_hash(:bool, var) }
        else
          build_matcher_hash(:root, var)
        end
      else
        reject_operator(matchers_conversions(var).first)
      end
    end

    def add_default_operator(var, types)
      operator = default_operator(types)
      var.each { |e| e[:operator] = operator unless e[:operator] }
    end

    def default_operator(types)
      if (types - [:root, :bool]).empty? || types == [:bool]
        :must
      elsif types == [:root]
        :and
      end
    end

    def reject_operator(hash)
      hash.reject { |k, _| k == :operator }
    end

    def initialize_query
      hash = { query: {} }
      hash[:query][:filtered] = { query: {} } if filtered.present?
      hash = { query: { function_score: hash } } if functions.present?
      hash
    end
  end
end
