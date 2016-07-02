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
