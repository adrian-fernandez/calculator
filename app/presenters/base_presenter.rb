# frozen_string_literal: true

class BasePresenter
  attr_reader :object, :data, :error, :error_message
  private :object
  private :data, :error, :error_message

  def initialize(**options)
    options.each do |key, value|
      instance_variable_set(:"@#{key}", value)
    end
  end

  def call
    return payload if object.valid

    payload_error
  end

  def payload_error
    {
      payload: object.payload,
      valid: object.valid
    }
  end
end
