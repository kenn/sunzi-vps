require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test

namespace :vcr do
  task :refresh do
    FileUtils.rm_f('test/vcr/vps_up.yml')
    Rake::Task['test'].invoke
  end
end
