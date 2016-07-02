# Hydrogel

A cool query builder for Elasticsearch requests with possibility to use chainable methods.

## Installation

> Gem for now is in developing stage and is on hard working. When everything will be enough for release next words will be true :-).

Add this line to your application's Gemfile:

```ruby
gem 'hydrogel'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hydrogel

## Usage

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

for searching for `Article` we can just write:
```ruby
Article.filter(term: { a: 1 })
       .query(match: { b: 'a' })
       .filtered(terms: { c: [1] })
       .fields(:f1, :f2)
       .page(2).per_page(10)
```

which is much more like ruby way.

## Contributing

1. Fork it ( https://github.com/imdrasil/hydrogel/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
