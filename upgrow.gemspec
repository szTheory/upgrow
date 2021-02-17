# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'upgrow'
  spec.version = '0.0.1'
  spec.author = 'Shopify Engineering'
  spec.email = 'gems@shopify.com'
  spec.homepage = 'https://github.com/Shopify/upgrow'
  spec.summary = 'Patterns for Rails Architecture'
  spec.license = 'MIT'

  spec.metadata = {
    'source_code_uri' =>
      "https://github.com/Shopify/upgrow/tree/v#{spec.version}",
    'allowed_push_host' => 'https://rubygems.org',
  }

  spec.files = Dir['lib/**/*', 'Rakefile', 'README.md']
  spec.test_files = Dir['test/**/*.rb']
  spec.require_paths = ['lib']
end
