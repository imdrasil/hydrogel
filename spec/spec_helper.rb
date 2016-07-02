require 'bundler/setup'
Bundler.setup

require 'pry'
require 'hydrogel'
require 'factory_girl'
require 'active_record'
require 'ansi'

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

      def self.setup(port = 9250)
        ActiveRecord::Base.establish_connection( :adapter => 'sqlite3', :database => ":memory:" )
        logger = ::Logger.new(STDERR)
        logger.formatter = lambda { |s, d, p, m| "\e[2;36m#{m}\e[0m\n" }
        ActiveRecord::Base.logger = logger unless ENV['QUIET']

        ActiveRecord::LogSubscriber.colorize_logging = false
        ActiveRecord::Migration.verbose = false

        tracer = ::Logger.new(STDERR)
        tracer.formatter = lambda { |s, d, p, m| "#{m.gsub(/^.*$/) { |n| '   ' + n }.ansi(:faint)}\n" }

        Elasticsearch::Model.client = Elasticsearch::Client.new host: "localhost:#{(ENV['TEST_CLUSTER_PORT'] || port)}",
                                                                tracer: (ENV['QUIET'] ? nil : tracer)
      end

      def self.base_setup
        setup(9200)
      end
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
    Elasticsearch::Test::IntegrationTestCase.base_setup
    Migration.migrate
    Migration.create_indexes
  end
end
