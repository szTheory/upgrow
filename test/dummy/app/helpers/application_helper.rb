# frozen_string_literal: true
module ApplicationHelper
  class BulmaFormBuilder < ActionView::Helpers::FormBuilder
    # Generic field wrapper for form inputs.
    #
    # It wraps the given block in a field div. In case a method is specified it
    # also prepends a label tag for the input and renders any errors for the
    # given method after the input.
    #
    # @param method [Symbol] the optional method to be called from the object
    #   this form builder is attached to.
    # @param label [Boolean] if the field needs a label or not.
    # @param addons [Boolean] if the field will have addons.
    #
    # @return [String] an HTML safe markup content.
    def field(method: nil, label: true, addons: false)
      field_class = ['field']
      field_class << 'has-addons' if addons
      @template.content_tag(:div, class: field_class) do
        result = ''.html_safe

        result += label(method, class: 'label') if method && label
        result += yield

        if method
          errors_for(method).each do |error|
            result += @template.content_tag(:p, error, class: 'help is-danger')
          end
        end

        result
      end
    end

    # Render a text-type input.
    #
    # @param method [Symbol] the method to be called from the object this form
    #   builder is attached to.
    # @param label [Boolean] if the input requires a label.
    # @param expanded [Boolean] if the control element will be expanded.
    # @param field [Boolean] if the text will be wrapped within a field.
    # @param args [Hash] optional arguments for the overloaded text_field
    #   method.
    #
    # @return [String] an HTML safe markup content.
    def text_field(method, label: true, expanded: false, field: true, **args)
      input_class = ['input']
      input_class << 'is-danger' if errors_for(method).any?
      output = control(expanded: expanded) do
        super(method, class: input_class, **args)
      end

      if field
        field(method: method, label: label) { output }
      else
        output
      end
    end

    def text_area(method, **args)
      input_class = ['textarea']
      input_class << 'is-danger' if errors_for(method).any?

      output = control(expanded: false) do
        super(method, class: input_class, **args)
      end

      field(method: method, label: true) { output }
    end

    # Render a form submit button.
    #
    # @param text [Symbol] the text for the button.
    # @param field [Boolean] if the button is within a field.
    # @param data [Hash] the HTML data attribute.
    #
    # @return [String] an HTML safe markup content.
    def submit(text, field: true, data: {})
      output = control { super(text, class: 'button is-primary', data: data) }
      if field
        field { output }
      else
        output
      end
    end

    private

    def control(expanded: false)
      control_class = ['control']
      control_class << ['is-expanded'] if expanded
      @template.content_tag(:p, class: control_class) do
        yield
      end
    end

    def errors_for(method)
      (options[:errors] || ActiveModel::Errors.new(self))
        .full_messages_for(method)
    end
  end
end
