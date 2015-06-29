# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'traffiq/version'

Gem::Specification.new do |spec|
  spec.name          = "traffiq"
  spec.version       = Traffiq::VERSION
  spec.authors       = ["Ride"]
  spec.email         = ["nicolas@ride.com"]
  spec.summary       = %q{Simple queue helpers for Ride.}
  spec.description   = %q{Simple queue helpers for Ride.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'oj', '~> 2.12'
  spec.add_dependency 'bunny', '>= 1.5.1', '< 2.0'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
