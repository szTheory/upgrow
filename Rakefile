# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.warning = true
  t.verbose = true
  t.test_files = FileList['test/**/*.rb']
end

require 'rubocop/rake_task'

RuboCop::RakeTask.new

task default: [:test, :rubocop]
