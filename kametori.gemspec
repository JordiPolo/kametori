# -*- encoding: utf-8 -*-
require File.expand_path('../lib/kametori/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "kametori"
  gem.authors       = ["Jordi Polo Carres"]
  gem.email         = ["mumismo@gmail.com"]
  gem.description   = %q{A gem to create benchmark suites for your app. It allows you to keep track of your performance}
  gem.summary       = %q{A gem to create benchmark suites for your app. }
  gem.homepage      = "http://www.github.com/JordiPolo/kametori"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "kametori"
  gem.require_paths = ["lib"]
  gem.version       = Kametori::VERSION

  gem.add_development_dependency("rspec", [">= 2.2.0"])
end
