require 'spec_helper'

RSpec.describe Hydrogel::Query do
  subject { described_class.new(Article) }

  let(:hash) { { field1: 1, Hydrogel::Query::OP => :must } }
  %i(filtered filter fields no_fields query).each do |var|
    let(var) { subject.instance_variable_get("@#{var}") }
  end

  describe '#terms' do
    it 'by default adds to filtered' do
      subject.terms(hash)
      expect(filtered.size).to eq(1)
      expect(filtered[0]).to include(operator: hash[:_op], terms: { field1: 1 })
    end

    it 'gets specified location' do
      subject.terms(:filter, hash)
      expect(filter[0]).to include(operator: hash[:_op], terms: { field1: 1 })
    end
  end

  describe '#fields' do
    it 'adds given fields to @fields and disable no_fields' do
      expected_fields = [:a, :b]
      subject.fields(*expected_fields)
      expect(fields).to match_array(expected_fields)
      expect(no_fields).to be false
    end
  end

  describe '#no_fields' do
    it 'adds given fields to @fields and disable no_fields' do
      subject.fields(:a, :b).no_fields
      expect(fields).to be_empty
      expect(no_fields).to be true
    end
  end

  describe '#prepare_arguments' do
    it 'accepts array of hashes' do
      res = subject.send(:prepare_arguments, [hash, hash])
      expect(res).to be_a Array
      expect(res.size).to eq(2)
      expect(res[0]).to be_a Hash
    end

    it 'convert hash to array of hashes' do
      res = subject.send(:prepare_arguments, hash)
      expect(res).to be_a Array
      expect(res[0]).to be_a Hash
    end

    it 'adds "operator" key to each element' do
      expect(subject.send(:prepare_arguments, hash)[0]).to include(:operator)
    end
  end

  describe '#reject_operator' do
    it 'remove operator from arguments' do
      expect(subject.send(:reject_operator, hash)).not_to include(:operator)
    end
  end

  describe '#match' do
    it 'uses default location (query)' do
      subject.match(a: 1)
      expect(query).to eq([match: { a: 1 }, operator: nil])
    end
  end
end
