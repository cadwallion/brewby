# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.authors       = ["Andrew Nordman"]
  gem.email         = ["cadwallion@gmail.com"]
  gem.summary       = %q{The core components of the Brewby brewing system}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "brewby"
  gem.require_paths = ["lib"]
  gem.version       = "0.1.1"

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'pry'

  gem.add_dependency 'temper-control'
end
