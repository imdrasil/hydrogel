# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hydrogel/version'

Gem::Specification.new do |spec|
  spec.name          = "hydrogel"
  spec.version       = Hydrogel::VERSION
  spec.authors       = ["Roman"]
  spec.email         = ["moranibaca@gmail.com"]
  spec.summary       = 'Gem for constructing chaineable requests for ElasticSearch'
  spec.description   = 'Gem for constructing chaineable requests for ElasticSearch'
  spec.homepage      = "https://github.com/imdrasil/hydrogel"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'elasticsearch-model'
  spec.add_development_dependency 'elasticsearch-persistence'
  spec.add_development_dependency 'elasticsearch-rails'
  spec.add_development_dependency 'activerecord'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'factory_girl'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency 'ansi'
  spec.add_runtime_dependency 'httparty'
  spec
end
