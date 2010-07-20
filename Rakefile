require 'rake/testtask'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/clean'

CLOBBER.include('pkg', 'doc')

Rake::TestTask.new('test') do |t|
  t.pattern = 'test/**/tc_*.rb'
  t.warning = true
end

spec = eval open('ruby-ogg.gemspec').read

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
  pkg.need_tar = false
  pkg.need_zip = false
end

rdoc_dir = 'doc'

Rake::RDocTask.new('rdoc') do |t|
  t.rdoc_dir = rdoc_dir
  t.rdoc_files.include('README.rdoc', 'lib/**/*.rb')
  t.main = 'README.rdoc'
  t.title = "#{spec.name}-#{spec.version} API documentation"
end

rubyforge_user = 'dismal_denizen'
rubyforge_path = "/var/www/gforge-projects/#{spec.rubyforge_project}/"
desc 'Upload documentation to RubyForge.'

task 'upload-docs' => ['rdoc'] do
  sh "scp -r #{rdoc_dir}/* #{rubyforge_user}@rubyforge.org:#{rubyforge_path}"
end

