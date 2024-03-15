# frozen_string_literal: true

# Handler for Redis cache
module Cache
  class Redis < BaseService
    def fetch
      Rails.logger.info "Fetching from redis... #{key}"

      $redis.get(key)
    end

    def persist(value)
      $redis.set(key, value.to_json)

      key_root = key.split('_').first

      {
        count: $redis.keys.count { |x| x.starts_with?(key_root) },
        key: key_root
      }
    end

    private

    def key
      @key ||= "#{@service.to_s.parameterize}_#{@params.to_s.parameterize}"
    end
  end
end
