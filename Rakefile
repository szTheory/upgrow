# frozen_string_literal: true

require 'bundler/setup'
require 'bundler/gem_tasks'

APP_RAKEFILE = File.expand_path('test/dummy/Rakefile', __dir__)
load('rails/tasks/engine.rake')

require 'rubocop/rake_task'

RuboCop::RakeTask.new

task default: ['db:setup', 'app:test:all', 'rubocop']
