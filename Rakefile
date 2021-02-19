# frozen_string_literal: true

require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.warning = true
  t.verbose = true
end

require 'rubocop/rake_task'

RuboCop::RakeTask.new

task default: [:test, :rubocop]
