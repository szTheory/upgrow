# frozen_string_literal: true

require 'test_helper'

module Upgrow
  class ModelTest < ActiveSupport::TestCase
    test '.new returns a Model class with the given members, id, and timestamps' do
      model_class = Model.new(:name)
      assert_equal([:name, :id, :created_at, :updated_at], model_class.members)
    end
  end
end
