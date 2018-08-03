# require "bundler/gem_tasks"
# require 'rake/testtask'
# require "test/unit"



# Rake::TestTask.new do |t|
#   t.libs << "test"
#   t.test_files = FileList['test/tc*.rb']
#   t.verbose = true
# end

# task :default => :test


require 'rake/testtask'
# require "test/unit"

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/tc*.rb']
  t.verbose = true
end

desc "Run tests"
task :default => :test