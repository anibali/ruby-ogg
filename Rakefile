require "bundler/gem_tasks"
require "rake/testtask"
require "yard"

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/tc_*.rb']
  t.verbose = true
end

YARD::Rake::YardocTask.new
