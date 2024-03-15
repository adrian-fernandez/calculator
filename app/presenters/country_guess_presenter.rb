# frozen_string_literal: true

class CountryGuessPresenter < BasePresenter
  attr_reader :requested_name, :time_processed
  private :requested_name, :time_processed

  def payload
    {
      guessed_country: object.payload,
      requested_name:,
      time_processed:
    }
  end
end
