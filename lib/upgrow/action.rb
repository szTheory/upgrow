# frozen_string_literal: true

module Upgrow
  # Actions represent the entry points to the app’s core logic. These objects
  # coordinate workflows in order to get operations and activities done.
  # Ultimately, Actions are the public interface of the app’s business layers.
  #
  # Rails controllers talk to the app’s internals by sending messages to
  # specific Actions, optionally with the required inputs. Actions have a
  # one-to-one relationship with incoming requests: they are paired
  # symmetrically with end-user intents and demands. This is quite a special
  # requirement from this layer: any given HTTP request handled by the app
  # should be handled by a single Action.
  #
  # The fact that each Action represents a meaningful and complete
  # request-response cycle forces modularization for the app’s business logic,
  # exposing immediately complex relationships between objects at the same time
  # that frees up the app from scenarios such as interdependent requests. In
  # other words, Actions do not have knowledge or coupling between other Actions
  # whatsoever.
  #
  # Actions respond to a single public method perform. Each Action defines its
  # own set of required arguments for perform, as well what can be expected as
  # the result of that method.
  class Action
    class << self
      attr_writer :result_class

      # Each Action class has its own Result class with the expected members to
      # be returned when the Action is called successfully.
      #
      # @return [Result] the Result class for this Action, as previously
      #   defined, or a Result class with no members by default.
      def result_class
        @result_class ||= Result.new
      end

      # Sets the Action Result class with the given members.
      #
      # @param args [Array<Symbol>] the list of members for the Result class.
      def result(*args)
        @result_class = Result.new(*args)
      end
    end

    # Instance method to return the Action's Result class. This method delegates
    # to the Action class's mehtod (see #result_class).
    #
    # @return [Result] the Result class for this Action.
    def result
      self.class.result_class
    end
  end
end
