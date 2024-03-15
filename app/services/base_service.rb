# frozen_string_literal: true

# Base structure for services
class BaseService
  Result = Struct.new(:payload, :valid)

  attr_reader :data, :error, :error_message
  private :data, :error, :error_message

  def initialize(**options)
    options.each do |key, value|
      instance_variable_set(:"@#{key}", value)
    end

    @error = false
  end

  def self.call(**args)
    new(**args).call
  end

  def call
    Result.new(payload:, valid: valid?)
  end

  protected

  def valid?
    !error
  end

  def error!(message)
    @error = true
    @error_message = message
  end
end
