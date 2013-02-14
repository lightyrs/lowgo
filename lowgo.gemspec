# encoding: utf-8
require File.expand_path('../lib/lowgo/version', __FILE__)

Gem::Specification.new do |gem|
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rdiscount'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'awesome_print'
  gem.add_runtime_dependency     'nokogiri'
  gem.add_runtime_dependency     'fb_graph'
  gem.add_runtime_dependency     'crunchbase'
  gem.author      = 'Harris Novick'
  gem.description = %q{Get logo images by brand or url.}
  gem.email       = 'harris@harrisnovick.com'
  gem.executables = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  gem.files       = `git ls-files`.split("\n")
  gem.homepage    = 'http://github.com/lightyrs/lowgo'
  gem.name        = 'lowgo'
  gem.require_paths = ['lib']
  gem.summary     = %q{Get logo images by brand or url.}
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.version     = Lowgo::VERSION
end
