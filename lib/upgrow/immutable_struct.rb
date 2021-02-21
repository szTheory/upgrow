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

    # Initializes a new Immutable Struct with the given member values.
    #
    # @param args [Hash<Symbol, Object>] the list of values for each member of
    #   the Immutable Struct.
    def initialize(**args)
      members.each { |key| args.fetch(key) }
      super(**args)
    end
  end
end
