# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name        = 'insidious'
  spec.version     = '0.1'
  spec.summary     = 'A simple and flexible ruby gem for managing daemons.'
  spec.authors     = ['James White']
  spec.email       = ['dev.jameswhite@gmail.com']
  spec.homepage    = 'https://github.com/jamesrwhite/insidious'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 1.9.3g'

  spec.require_paths = ['lib']
  spec.files         = Dir['Rakefile', 'README.md', 'LICENSE', '{lib,spec}/**/*']
  spec.test_files    = Dir['{spec}/**/*']
end
