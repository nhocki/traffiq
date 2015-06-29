require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs = [ "test" ]
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
  # TODO: AMQP has a lot of warnings. Fix them and turn this on.
  # t.warning = true
end

task :default => [ :test ]
