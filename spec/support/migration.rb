require 'factory_girl'

class Migration
  class << self
    def migrate
      this = self
      ActiveRecord::Schema.define(version: 1) do
        this.send(:create_article, self)
      end
    end

    def create_indexes
      Article.__elasticsearch__.create_index!
    end

    def up
      setup_env
      migrate
      create_indexes
      3.times do |i|
        Track.create(title: "Track #{i}")
        Article.create(title: "Article #{i}")
      end
      Article.import
      sleep 1
    end

    def down
      Hydrogel::Curl.delete_index(Article.index_name)
    end

    def setup_env
      ActiveRecord::Base.establish_connection( :adapter => 'sqlite3', :database => ":memory:" )
      logger = ::Logger.new(STDERR)
      logger.formatter = lambda { |s, d, p, m| "\e[2;36m#{m}\e[0m\n" }
      ActiveRecord::Base.logger = logger unless ENV['QUIET']

      ActiveRecord::LogSubscriber.colorize_logging = false
      ActiveRecord::Migration.verbose = false

      tracer = ::Logger.new(STDERR)
      tracer.formatter = lambda { |s, d, p, m| "#{m.gsub(/^.*$/) { |n| '   ' + n }.ansi(:faint)}\n" }

      Elasticsearch::Model.client = Elasticsearch::Client.new host: "localhost:#{(ENV['TEST_CLUSTER_PORT'] || 9200)}",
                                                              tracer: (ENV['QUIET'] ? nil : tracer)
    end

    private

    def create_article(schema)
      schema.create_table(:articles) do |t|
        t.string :title
        t.string :genre
        t.text :text
      end
    end
  end
end
