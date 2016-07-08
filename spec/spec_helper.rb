require 'bundler/setup'
Bundler.setup

require 'pry'
require 'elasticsearch/model'
require 'elasticsearch/persistence/model'
require 'factory_girl'
require 'active_record'
require 'ansi'

require 'hydrogel'

require 'support/models/article'
require 'support/persistences/track'
require 'support/migration'

Dir[File.join(File.dirname(__FILE__), 'factories', '*')].each do |path|
  require path.split('.').first
end

module Elasticsearch
  module Test
    class IntegrationTestCase
      # startup  { Elasticsearch::Extensions::Test::Cluster.start(nodes: 1) if ENV['SERVER'] and not Elasticsearch::Extensions::Test::Cluster.running? }
      # shutdown { Elasticsearch::Extensions::Test::Cluster.stop if ENV['SERVER'] && started? }
    end
  end
end

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.order = :random
  Kernel.srand config.seed

  config.before(:each) do
    Hydrogel::Config.reset
  end

  config.before(:suite) do
    Migration.up
  end

  config.after(:suite) do
    Migration.down
  end
end
