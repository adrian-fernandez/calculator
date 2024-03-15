# frozen_string_literal: true

module Api
  class FamilySearch
    Result = Struct.new(:name, :accuracy)

    BASE_URL = 'https://www.familysearch.org/service/home/discovery/api/v1/quick-search/search/surname'
    USER_AGENT = [
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
      '(KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36'
    ].join(' ')
    ERROR_TXT = 'Error fetching data from FamilySearch'

    API_QUERY_PARAM_SURNAME = 'q.surname'

    API_RESPONSE_FIELD_TOTAL_COUNT = %w[surname count].freeze
    API_RESPONSE_STRUCT = %w[surname countries].freeze
    API_RESPONSE_FIELD_COUNT = 'count'
    API_RESPONSE_FIELD_NAME = 'name'

    def initialize(query)
      @query = query
    end

    def call
      response = ::Faraday.get(BASE_URL, params, headers)

      raise ApiError, ERROR_TXT unless response.success?

      build_results(JSON.parse(response.body))
    rescue Faraday::Error => e
      raise ApiError, "#{ERROR_TXT}: #{e.message}"
    end

    private

    def build_results(data)
      countries = data.dig(*API_RESPONSE_STRUCT)

      raise ApiError, ERROR_TXT unless countries.is_a?(Array)

      (countries.first || []).fetch('code', '')
    end

    def params
      {
        API_QUERY_PARAM_SURNAME => @query
      }
    end

    def headers
      {
        Accept: 'application/json',
        'USER-AGENT' => USER_AGENT
      }
    end
  end
end
