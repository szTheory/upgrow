# frozen_string_literal: true

require 'test_helper'
require 'yard'

module Upgrow
  class DocumentationTest < ActiveSupport::TestCase
    test 'documentation is correctly written' do
      assert_empty(%x(bundle exec yard --no-save --no-output --no-stats))
    end
  end
end
