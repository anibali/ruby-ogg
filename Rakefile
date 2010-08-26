require 'rubygems'
require 'burke'

Burke.enable_all

Burke.setup do |s|
  s.name = 'ruby-ogg'
  s.summary = 'A pure Ruby library for reading Ogg bitstreams, with a bundled Vorbis metadata reader.'
  s.author = 'Aiden Nibali'
  s.email = 'dismal.denizen@gmail.com'
  s.rubyforge_project = 'ruby-ogg'
  s.homepage = 'http://github.com/dismaldenizen/ruby-ogg'
  
  s.dependencies do |d|
    d.bindata '~> 1.0'
  end
  
  s.has_rdoc = true
  
  s.clean = %w[.yardoc]
  s.clobber = %w[pkg doc html]
  
  s.gems.platform 'ruby'
end

rubyforge_user = 'dismal_denizen'
rubyforge_web_path = "/var/www/gforge-projects/#{Burke.settings.rubyforge_project}/"

desc 'Upload YARD docs to RubyForge'
task 'yard:upload' => ['yard'] do
  sh "scp -r doc/* #{rubyforge_user}@rubyforge.org:#{rubyforge_web_path}"
end

desc 'Upload RDoc docs to RubyForge'
task 'rdoc:upload' => ['rdoc'] do
  sh "scp -r html/* #{rubyforge_user}@rubyforge.org:#{rubyforge_web_path}"
end

