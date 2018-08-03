require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/ts*.rb']
  t.verbose = true
end

desc "Run tests"
task :default => :test