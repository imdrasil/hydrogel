require 'spec_helper'

RSpec.describe Hydrogel::RequestBuilder do
  let(:builder) { described_class.new(request) }
  let(:request) { Hydrogel::Query.new(Article) }
  let(:functions) do
    [
      {
        filter: { term: { 'rights.hit' => 1 } },
        boost_factor: 2
      },
      {
        filter: { not: { term: { 'popularity.popularity' => 0 } } },
        field_value_factor: { field: 'popularity.popularity', modifier: 'log1p', factor: 1.5 }
      }
    ]
  end

  describe '#build_hash' do
    subject { builder.send(:build_hash) }
    let(:query) { { match: { b: 'a' } } }
    let(:filter) { { term: { a: 1 } } }
    let(:filtered) { { terms: { c: [1] } } }
    let(:fields) { [:f1, :f2] }
    let(:page) { 2 }
    let(:facets) { { test: { term: { field: :tag } } } }

    it 'adds all parts if them was given' do
      request.filter(filter).query(query).filtered(filtered).fields(*fields).page(page).facets(facets)
      expect(subject[:query][:filtered][:query]).to include(query)
      expect(subject[:query][:filtered][:filter]).to include(filtered)
      expect(subject[:filter]).to include(filter)
      expect(subject[:size]).to eq(Hydrogel::Config.per_page)
      expect(subject[:from]).to eq(page * Hydrogel::Config.per_page)
      expect(subject[:fields]).to eq(fields)
      expect(subject[:facets]).to include(facets)
    end

    it 'stack together several queries' do
      q1 = { terms: { field2: [1, 2] } }
      q2 = { term: { field: 1 } }
      request.query(term: { field: 1 }).query(terms: { field2: [1, 2] })
      expect(subject[:query][:bool][:must]).to match_array([q1, q2])
    end

    it 'correctly add query part if function score is given' do
      request.function_score(functions).query(query)
      expect(subject[:query][:function_score][:query]).to eq(query)
    end

    it 'correctly works with multiple query and filtered' do
      request.function_score(functions).query(query.merge(_op: :should)).query(query.merge(_op: :should))
        .filtered(terms: { field1: [2] }).fields(term: { field2: '2' })
      expect(subject[:query][:function_score][:query][:filtered][:query][:bool][:should]).to eq([query] * 2)
      expect(subject[:query][:function_score][:query][:filtered][:filter]).to eq(terms: { field1: [2] })
    end
  end

  describe '#additional_get_attrs' do
    subject { builder.send(:additional_get_attrs, {}) }

    let(:index) { 'some_index' }

    it 'added index to attributes if it was given' do
      request.index(index)
      expect(subject[:index]).to eq([index])
    end
  end

  describe '#add_query_part_to_hash' do
    # TODO: rewrite to separate method call
    subject { builder.send(:build_hash) }

    let(:query) { { match: { b: 2 } } }

    it 'adds query to filtered part if query filter is given' do
      request.filtered(terms: { a: [1] }).query(query)
      expect(subject[:query]).to include(:filtered)
      expect(subject[:query][:filtered]).to include(query: query)
    end

    it 'adds query to root query part if no query filter was given' do
      request.query(query)
      expect(subject).to include(query: query)
    end

    it 'adds "match_all" if no query given' do
      request.filter(terms: { a: [1] })
      expect(subject).to include(query: { match_all: {} })
    end
  end

  describe '#build_query_part' do
    subject { builder.send(:build_hash) }

    it 'correctly generate hash if query is specified too' do
      query = 'quick brown f'
      options = { type: 'phrase_prefix' }
      fields = %w(subject message)
      expected = {
          query: {
              multi_match: {
                  query: query,
                  fields: fields
              }.merge(options)
          }
      }
      request.multi_match(query, fields, options).match(field1: 'a')
      expect(subject).to include(expected) #TODO: make it more clear
    end
  end

  describe '#add_functions' do
    # dsl = {
    #   query: {
    #     multi_match: {
    #       query: 'asdasd',
    #       fields: %w(artist.title title artist.title.autocomplete^1.5 title.autocomplete),
    #       type: 'cross_fields',
    #       minimum_should_match: '33%'
    #     }
    #   }
    # }
    # functions = {
    #     functions: [
    #         {
    #             filter: { term: { 'rights.hit' => 1 } },
    #             boost_factor: 2
    #         },
    #         {
    #             filter: { not: { term: { 'popularity.popularity' => 0 } } },
    #             field_value_factor: { field: 'popularity.popularity', modifier: 'log1p', factor: 1.5 }
    #         }
    #     ]
    # }
    # dsl.update functions
    # a = ::Track.search page: 1, per_page: 10, index: ['labeled'] do |s|
    #   s.query { |q| q.raw_dsl(:function_score, dsl) }
    #   s.filter(:bool, must: [{ match_all: {} }])
    #   s.query { |q| q.match %w(title artist.title), 'asd' }
    # end

    subject { builder.send(:build_hash) }

    it 'correctly adds multiple functions' do
      query = { match: { asd: 'a1' } }
      request.function_score(functions).query(query)
      expect(subject[:query][:function_score][:functions]).to eq(functions)
    end

    it 'correctly adds one function' do
      request.function_score(filter: { term: { id: 1 } })
      expect(subject[:query][:function_score][:functions]).to eq([{ filter: { term: { id: 1 } } }])
    end

    it 'adds score_mode' do
      request.function_score(:multiply, functions)
      expect(subject[:query][:function_score][:functions]).to eq(functions)
      expect(subject[:query][:function_score][:score_mode]).to eq(:multiply)
    end
  end
end
