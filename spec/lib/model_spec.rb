require 'spec_helper'
require 'support/shared/search_methods'

RSpec.describe Hydrogel::Model do
  it_behaves_like 'common searchable', Article
  it_behaves_like 'common searchable', Track
end
