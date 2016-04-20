# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ifirma/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Piotr Sarnacki"]
  gem.email         = ["drogus@gmail.com"]
  gem.description   = %q{API wrapper for ifirma.pl}
  gem.summary       = %q{API wrapper for ifirma.pl}
  gem.homepage      = ""

  gem.add_dependency 'faraday', '~> 0.9.2'
  gem.add_dependency 'faraday_middleware'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'webmock'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "ifirma"
  gem.require_paths = ["lib"]
  gem.version       = Ifirma::VERSION
end
