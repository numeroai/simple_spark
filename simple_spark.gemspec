# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_spark/version'

Gem::Specification.new do |spec|
  spec.name          = 'simple_spark'
  spec.version       = SimpleSpark::VERSION
  spec.authors       = ['Jak Charlton']
  spec.email         = ['jakcharlton@gmail.com']
  spec.summary       = 'A library for accessing the SparkPost REST API http://www.sparkpost.com'
  spec.description   = 'An alternative to the official SparkPost Ruby gem'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']


  spec.add_dependency 'json', '>= 1.7.7', '< 3.0'
  spec.add_dependency 'excon', '>= 0.16.0', '< 2.0'
end
