# frozen_string_literal: true

require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

APP_RAKEFILE = File.expand_path('test/dummy/Rakefile', __dir__)
load('rails/tasks/engine.rake')
task 'test:system' => 'app:test:system' # Hack to use the test environment.

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/upgrow/**/*_test.rb'
  t.warning = true
  t.verbose = true
end

RuboCop::RakeTask.new

task default: ['rubocop', 'test', 'db:setup', 'test:system']
