require 'rubygems'

spec = Gem::Specification.new do |spec|
  spec.name = 'ruby-ogg'
  spec.version = '0.0.0'
  spec.summary = 'A library for reading Ogg bitstreams'
  spec.author = 'Aiden Nibali'
  spec.email = 'dismal.denizen@gmail.com'
  spec.rubyforge_project = 'ruby-ogg'
  spec.homepage = 'http://rubyforge.org/projects/ruby-ogg/'
  spec.files = Dir['lib/*.rb']
  spec.add_dependency('bindata', '>= 1.0.0')
end

