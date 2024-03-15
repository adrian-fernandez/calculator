# frozen_string_literal: true

# Service to guess the original country of a given surname.
# By default it uses Api::FamilySearch API wrapper but it can be extended with other providers
class CountryGuessService < BaseService
  DEFAULT_API_SERVICE = Api::FamilySearch

  attr_reader :api
  private :api

  def initialize(data:, api: nil)
    super(data:)

    @api = api || DEFAULT_API_SERVICE.new(data)
  end

  def payload
    @payload ||= begin
      api_proc = method(:fetch_from_api).to_proc

      CacheService.call(service: api.class.to_s, params: data, format: :json,
                        api: api_proc)
    end
  rescue ::ApiError => e
    error!(e.message)
  end

  def valid?
    payload.present? && !error
  end

  private

  def fetch_from_api
    api.call
  end
end
