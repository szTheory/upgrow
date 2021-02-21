# frozen_string_literal: true

require 'test_helper'

module Upgrow
  class ActionTest < ActiveSupport::TestCase
    test '.result_class is an empty Result by default' do
      assert_equal([:errors], Action.result_class.members)
    end

    test '.result sets the members in the Action Result class' do
      result_class = Action.result_class

      Action.result(:user, :data)

      assert_equal([:user, :data, :errors], Action.result_class.members)

      Action.result_class = result_class
    end

    test '#result returns the Result class from the Action class' do
      assert_equal Action.result_class, Action.new.result
    end
  end
end
