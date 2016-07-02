require 'spec_helper'
require 'support/shared/search_methods'

RSpec.describe Hydrogel::Model do
  before(:all) do
    create_list(:article, 3)
    Article.import
  end

  it_behaves_like 'common searchable', Article
end
