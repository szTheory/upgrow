# frozen_string_literal: true
module Upgrow
  # A read-only Struct. An Immutable Struct is initialized with its member
  # values and subsequent state changes are not permitted.
  class ImmutableStruct < Struct
    class << self
      # Creates a new Immutable Struct class with the given members.
      #
      # @param args [Array<Symbol>] the list of members for the new class.
      #
      # @return [ImmutableStruct] the new Immutable Struct class able to
      #   accommodate the given members.
      def new(*args, &block)
        struct_class = super(*args, keyword_init: true, &block)

        struct_class.members.each do |member|
          struct_class.send(:undef_method, :"#{member}=")
        end

        struct_class
      end
    end

    undef []=
  end
end
