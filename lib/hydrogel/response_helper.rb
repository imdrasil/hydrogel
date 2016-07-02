module Hydrogel
  # TODO: is not finished and probably is useless
  # can be included by Elastisearch::Model::Response::Response
  # and Elastisearch::Persistence::Repository::Response::Results
  module ResponseHelper
    def per_page
      size
    end

    def pages
      per_page > 0 ? (total.to_f / per_page).ceil : 0
    end

    def total_count
      total
    end

    def total
      results.total
    end

    def facets
      response[:facets]
    end
  end
end
