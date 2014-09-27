# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruby-ogg/version'

Gem::Specification.new do |spec|
  spec.name          = "ruby-ogg"
  spec.version       = Ogg::VERSION
  spec.authors       = ["Aiden Nibali"]
  spec.email         = ["dismal.denizen@gmail.com"]
  spec.summary       = %q{A pure Ruby library for reading Ogg bitstreams, with a bundled Vorbis metadata reader.}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/anibali/ruby-ogg"

  spec.files         = `git ls-files`.split($/).reject {|s| s.start_with? "test"}
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "yard"

  spec.add_runtime_dependency "bindata", "~> 1.4"
end
