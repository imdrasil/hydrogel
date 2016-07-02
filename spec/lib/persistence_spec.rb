require 'spec_helper'
require 'support/shared/search_methods'

RSpec.describe Hydrogel::Persistence do
  before(:all) { 3.times { |i| Track.create(title: "Track #{i}") } }

  it_behaves_like 'common searchable', Track
end
