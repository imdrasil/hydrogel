require 'spec_helper'

RSpec.describe Hydrogel do
  it 'allow call all basic methods' do
    Hydrogel::BasicMethods::ALL_METHODS.each do |method|
      expect(described_class).to be_respond_to(method)
    end
  end

  describe '#h_search' do
    it 'returns hash with results' do
      expect(Hydrogel.h_search(query: { match_all: {} })).to be_a Hash
    end
  end

  describe '#extract_result' do
    let(:query) { { query: { match_all: {} } } }

    it 'extract only hits if hits params was given' do
      res = Hydrogel.h_search(query, extract: :hits)
      expect(res).to be_a Array
      expect(res.first.keys).to include('_source')
    end

    it 'extract sources if such argument was given' do
      res = Hydrogel.h_search(query, extract: :source)
      expect(res).to be_a Array
      expect(res.first.keys).to include('title')
    end
  end
end
