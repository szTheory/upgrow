# frozen_string_literal: true
module Upgrow
  # Results are special Structs that are generated dynamically to accommodate a
  # set of pre-defined members. Since different Actions might want to return
  # zero to multiple values, they are always returned as members of a Result
  # instance.
  #
  # Regardless of the values the Action might want to return, a Result has one
  # default member called errors, which holds any errors that might occur when
  # the Action is performed. If Result errors are empty, the Result is a
  # success; if there are errors present, however, the Result is a failure. This
  # empowers Actions with a predictable public interface, so callers can expect
  # how to evaluate if an operation was successful or not by simply checking the
  # success or failure of a Result.
  #
  # Additionally, Result instances behave like monadic values by offering
  # bindings to be called only in case of success or failure, which further
  # simplifies the caller’s code by not having to use conditional to check for
  # errors.
  class Result < ImmutableStruct
    class << self
      # Creates a new Result class that can handle the given members.
      #
      # @param members [Array<Symbol>] the list of members the new Result should
      #   be able to hold.
      #
      # @return [Result] the new Result class with the given members.
      def new(*members)
        super(*members, :errors)
      end

      # Returns a new Result instance populated with the given values.
      #
      # @param values [Hash<Symbol, Object>] the list of values for each member
      #   provided as keyword arguments.
      #
      # @return [Result] the Result instance populated with the given values.
      def success(*values)
        new(*values)
      end

      # Returns a new Result instance populated with the given errors.
      #
      # @param errors [ActiveModel::Errors] the errors object to be set as the
      #   Result errors.
      #
      # @return [Result] the Result instance populated with the given errors.
      def failure(errors)
        values = members.map { |member| [member, nil] }.to_h
        new(**values.merge(errors: errors))
      end
    end

    # Calls the given block only when the Result is successful.
    #
    # This method receives a block that is called with the Result values passed
    # to the block only when the Result itself is a success, meaning its list of
    # errors is empty. Otherwise the block is not called.
    #
    # It returns self for convenience so other methods can be chained together.
    #
    # @yield [values] gives the Result values to the block on a successful
    #   Result.
    #
    # @return [Result] self for chaining.
    def and_then
      yield(*values) if errors.none?
      self
    end

    # Calls the given block only when the Result is a failure.
    #
    # This method receives a block that is called with the Result errors passed
    # to the block only when the Result itself is a failure, meaning its list of
    # errors is not empty. Otherwise the block is not called.
    #
    # It returns self for convenience so other methods can be chained together.
    #
    # @yield [errors] gives the Result errors to the block on a failed Result.
    #
    # @return [Result] self for chaining.
    def or_else
      yield(errors) if errors.any?
      self
    end

    private

    def initialize(*args)
      values = { errors: [] }.merge(args.first || {})
      super(**values)
    end
  end
end
