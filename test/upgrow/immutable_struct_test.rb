# frozen_string_literal: true

require 'test_helper'

module Upgrow
  class ImmutableStructTest < ActiveSupport::TestCase
    test '.new creates a new Struct class with the given members as keyword arguments' do
      struct_class = ImmutableStruct.new(:user, :post)

      struct = struct_class.new(user: 'volmer', post: 'hello')

      assert_equal([:user, :post], struct.members)
      assert_equal(['volmer', 'hello'], struct.values)
    end

    test 'it does not respond to []=' do
      struct = ImmutableStruct.new(:user).new(user: 'volmer')
      refute struct.respond_to?(:[]=)
    end

    test 'it does not allow members to be mutated' do
      struct_class = ImmutableStruct.new(:user, :post)

      struct = struct_class.new(user: 'volmer', post: 'hello')

      refute struct.respond_to?(:user=)
      refute struct.respond_to?(:post=)
    end

    test '.new requires all members' do
      struct_class = ImmutableStruct.new(:user, :post)

      error = assert_raises(KeyError) do
        struct_class.new(user: 'volmer')
      end

      assert_equal 'key not found: :post', error.message
    end
  end
end
