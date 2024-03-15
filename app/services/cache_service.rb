# frozen_string_literal: true

# Service to restore and save values from the cache
# It uses two levels of caching: 1-Redis and 2-Database
class CacheService < BaseService
  STEPS = [
    Cache::Redis,
    Cache::Database
  ].freeze

  attr_reader :service, :params, :format, :api
  private :service, :params, :format, :api

  def call
    result = parse_value(fetch_from_cache) || fetch_from_api
    Rails.logger.info "Found: #{result.inspect}"

    result
  end

  private

  def fetch_from_cache
    result = nil

    STEPS.each do |step|
      result ||= step.new(service:, params:).fetch
    end

    result
  end

  def fetch_from_api
    Rails.logger.info 'Fetching from API...'
    result = api.call

    persisted_data = persist_in_redis(result)

    persist_in_db(persisted_data[:key]) if persisted_data[:count] >= ENV.fetch('CACHE_THRESHOLD',
                                                                               100)

    result
  end

  def persist_in_redis(value)
    Cache::Redis.new(service:, params:).persist(value)
  end

  def persist_in_db(key)
    ::DbCacheQueryPersistJob.perform_later(key)
  end

  def parse_value(value)
    return nil if value.nil?

    begin
      case format
      when :json
        JSON.parse(value)
      end
    rescue StandardError
      nil
    end
  end
end
