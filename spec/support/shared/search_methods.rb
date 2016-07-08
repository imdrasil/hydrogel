RSpec.shared_examples 'common searchable' do |klass|
  describe klass.to_s do
    describe 'class methods' do
      it 'adds all basic methods to class' do
        expect(klass).to be_respond_to(:h_search)
      end

      it 'adds all shortcuts' do
        Hydrogel::BasicMethods::ALL_METHODS.each do |method|
          expect(klass).to be_respond_to(method)
        end
      end

      describe '#h_search' do
        let(:response) do
          klass.superclass == ActiveRecord::Base ? Elasticsearch::Model::Response::Result : klass
        end

        it 'returns normal object' do
          #binding.pry
          puts '--'
          puts klass.h_search(query: { match_all: {} }).to_a.inspect
          expect(klass.h_search(query: { match: { title: '1' } }).first).to be_a(response)
        end
      end

      describe '#h_scope' do
        before(:all) { klass.h_scope :much, -> { many } }
        after(:all) { Hydrogel::Query.scopes[klass] = {} }

        it 'adds class methods' do
          expect(klass.respond_to?(:much)).to be true
        end

        it 'adds singleton instance method' do
          expect(Hydrogel::Query.new(klass).respond_to?(:much)).to be true
        end
      end

      describe '#h_default_scope' do
        before(:all) { klass.h_default_scope -> { many } }
        after(:all) { Hydrogel::Query.default_scopes[klass] = nil }

        it 'apply scopes before another methods' do
          expect(klass.size(10).instance_variable_get('@size')).to eq(10)
        end

        it 'automatically apply default scope' do
          expect(klass.filter(name: 'name').instance_variable_get('@size')).to eq(Hydrogel::Config.many_size)
        end
      end
    end
  end
end
