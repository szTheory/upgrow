# frozen_string_literal: true

require 'test_helper'

module Upgrow
  class ResultTest < ActiveSupport::TestCase
    setup do
      @errors = [:error]
    end

    test '.new returns a Result class with the given members and errors' do
      result_class = Result.new(:user)
      assert_equal([:user, :errors], result_class.members)
    end

    test '.new returns a Result class with only errors when called without arguments' do
      result_class = Result.new
      assert_equal([:errors], result_class.members)
    end

    test '.success returns a Result populated with the given values' do
      result = Result.new(:user).success(user: 'volmer')
      assert_equal 'volmer', result.user
      assert_empty result.errors
    end

    test '.failure returns a Result populated with the given errors' do
      result = Result.new(:user).failure(@errors)
      assert_nil result.user
      assert_equal @errors, result.errors
    end

    test '#and_then calls the given block and returns self for a successful Result' do
      called = false

      success = Result.new.success

      returned_value = success.and_then { called = true }

      assert called
      assert_equal success, returned_value
    end

    test '#or_else passes the Result values as an argument to the given block' do
      success = Result.new(:user, :post)
        .success(user: 'volmer', post: 'hello!')

      success.and_then do |user, post|
        assert_equal 'volmer', user
        assert_equal 'hello!', post
      end
    end

    test '#and_then does not call the given block and returns self for a failure Result' do
      called = false

      failure = Result.new.failure(@errors)

      returned_value = failure.and_then { called = true }

      refute called
      assert_equal failure, returned_value
    end

    test '#or_else does not call the given block and returns self for a successful Result' do
      called = false

      success = Result.new.success

      returned_value = success.or_else { called = true }

      refute called
      assert_equal success, returned_value
    end

    test '#or_else calls the given block and returns self for a failure Result' do
      called = false

      failure = Result.new.failure(@errors)

      returned_value = failure.or_else { called = true }

      assert called
      assert_equal failure, returned_value
    end

    test '#or_else passes the errors as an argument to the given block' do
      failure = Result.new.failure(@errors)

      failure.or_else do |errors|
        assert_equal @errors, errors
      end
    end
  end
end
