RSpec.shared_examples 'common searchable' do |klass|
  describe 'class methods' do
    it 'adds all basic methods to class' do
      (Hydrogel::BasicMethods::METHODS + [:h_search]).each do |method|
        expect(klass).to be_respond_to(method)
      end
    end

    it 'adds all shortcuts' do
      Hydrogel::Hook::ClassMethods::ALL_METHODS.each do |method|
        expect(klass).to be_respond_to(method)
      end
    end

    describe '#h_search' do
      let(:response) do
        klass.superclass == ActiveRecord::Base ? Elasticsearch::Model::Response::Result : klass
      end

      it 'returns normal object' do
        expect(klass.h_search(query: { match: { title: '1' } }).first).to be_a(response)
      end
    end
  end
end
