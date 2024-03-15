# frozen_string_literal: true

class CalculatorPresenter < BasePresenter
  attr_reader :expression
  private :expression

  def payload
    {
      expression:,
      result: object.payload
    }
  end
end
