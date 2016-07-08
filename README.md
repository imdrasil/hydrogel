# Hydrogel

A cool query builder for Elasticsearch requests with possibility to use chainable methods. For now it extends possibilities of [elasticsearch-rails gem](https://github.com/elastic/elasticsearch-rails), but in future it'll become standalone powerfull interface fior ElasticSearch search engine.

## Installation

> Gem for now is in developing stage and is on hard working. So first release to Rubygems will be very soon.

Add this line to your application's Gemfile:

```ruby
gem 'hydrogel'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hydrogel

### Dependencies

There is no hardcoded dependencies on any `elasticsearch-persistence` and `elastisearch-model` gems but it still needs one of them or both to work. 
Gem tested on 0.1.9 version of all `elasticsearch-*` gems.

Supported Rubies:
* 1.9.3 MRI
* 1.7.19 JRuby

## Usage
### Introduction
To generate something like:
```json
{
   "query": {
        "filtered":{
            "query":{
                "match": { "b": 'a' }
            },
            "filter":{
                "terms": { "c": [1] }
            }
        }
   },
   "filter":{
      "term": { "a": 1 }
   },
   "fields": ["f1", "f2"],
   "size": 10,
   "from": 20
}
```
for searching `Article` we can just write:
```ruby
Article.filter(term: { a: 1 })
       .query(match: { b: 'a' })
       .filtered(terms: { c: [1] })
       .fields(:f1, :f2)
       .page(2).per_page(10)
```
or even more shortly
```ruby
Article.term(:filter, a: 1).match(b: 'a')
       .terms(c: [1]).fields(:f1, :f2)
       .page(2).per_page(10)
```
which is much more like ruby way.

### Basic search methods

For searching via any index or types without no mapped class you can just write something like this:
```ruby
Hydrogel.match_all.type('article', 'track').result(extract: :source)
```

Also you can extend `Hydrogel::Model` both inside your model or persistence classes:
```ruby
require 'elasticsearch/model'
require 'elasticsearch/persistence/model'

class Article < ActiveRecord::Base
  include Elasticsearch::Model
  extend Hydrogel::Model

  index_name 'test_index'
end

class Track
  include Elasticsearch::Persistence::Model
  extend Hydrogel::Model

  index_name 'test_index'

  attribute :title, String
  attribute :genre, Integer
end
```

This allow you to use search methods on both classes and  get mapped results.

All requests are lazy - they will be gathered and made only when some iteration will appear. To get results at initialization line you can use `result` method.

Also you can specify where to put query part (to `must` subpart or `and`, etc.) using `:_op` option.
```ruby
Track.filter(term: { genre: 1 }, terms: { genre: [0] }, _op: :or)
```

The only restriction for this time is that you can use only one of `bool` and logical part in `query`, `filter` and `filtered` (but they can be different in each one) suparts of query.
#### Pagination

**Hydrogel** has no dependencies on any paginator and provides 2 methods for that:
- `page` - takes needed page number (starting form 1)
- `per_page` - takes number of records per each page (more or equal to 0; default value is got from configuration).

Also there is another way to do this task - using from-size arguments of ElasticSearch by hand. This way has higher priority during building query.

### Configuration

There are several parameters which can be configured:
- `host` - ElasticSearch host (default is `'http://localhost'`)
- `port` - ElasticSearch port number (default is `9200`)
- `many_size` - default number for `size`  attribute while calling `many` method (default is `1000`)
- `per_page` - default per page count (default is `10`).

You can specify all of them just adding such initializer:
```ruby
Hydrogel::Config.config do |conf|
    conf.port = 9050
    conf.per_page = 20
end
```

### Scoping

Also you can specify reusable chainable scopes for any model just using `h_scope` method:
```ruby
class Article
    h_scope :length, ->(a) { size(a) }
end 
```
> `Article` has been already initialized previously in [Basic search methods]() section.

Also you can specify default scope:
```ruby
class Article
    h_default_scope -> { per_page(100) }
end
```
To evoid default scope in certain request just call `h_unscoped` before at the very beginning.
```ruby
Article.h_unscoped.match_all
```

## Methods description

Methods for models and persistences:
#### result
Gets results of search request.
Arguments: `options = {}`
Allowed `options` keys:
- page - page number,
- per_page - per page size
- extract - for extracting some data from response(`:hits` - for extracting 'hits' part, `:source` - for extracting only sources, `:fields` - for fields extracting)
- any valid option for `search` method of `elasticsearch-api` gem

#### query
Adds hash for `"query"` subpart.

#### filter

#### filtered

#### facets

#### aggs

#### multi_match

#### function_score

#### terms

#### term

#### ids

#### range

#### match

#### common

#### prefix

#### wildcard

#### regexp

#### fuzzy

#### count

#### many

#### match_all

#### pluck

#### index

#### type

#### page

#### per_page

#### fields

#### no_fields

#### from 

#### size

#### sort_by

#### order

> Descriptions for all these methods will appear in close future.

## Contributing

1. Fork it ( https://github.com/imdrasil/hydrogel/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
