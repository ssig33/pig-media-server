# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pig-media-server/version'

Gem::Specification.new do |gem|
  gem.name          = "pig-media-server"
  gem.version       = PigMediaServer::VERSION
  gem.authors       = ["ssig33"]
  gem.email         = ["mail@ssig33.com"]
  gem.description   = %q{Pig Media Server}
  gem.summary       = %q{Pig Media Server}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = %w(pig-media-server)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'rroonga'
  gem.add_dependency 'sinatra'
  gem.add_dependency 'haml'
  gem.add_dependency 'sass'
  gem.add_dependency 'rack_csrf'
  gem.add_dependency 'unicorn'
  gem.add_dependency 'pit'
  gem.add_dependency 'sewell'
  gem.add_dependency 'coffee-script'
  gem.add_dependency 'sinatra-flash'
end
