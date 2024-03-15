# frozen_string_literal: true

require 'digest'

# Handler for Database cache.
module Cache
  class Database < BaseService
    def fetch
      Rails.logger.info "Fetching from database... #{key}"

      ::CachedQuery.find_by(key:).try(:value)
    end

    # rubocop:disable Rails/SkipsModelValidations
    def self.persist(key_root)
      to_insert = []
      keys = $redis.keys.select { |x| x.starts_with?(key_root) }

      keys.each do |k|
        to_insert << { key: k, value: $redis.get(k) }
      end

      CachedQuery.insert_all(to_insert)

      keys.each do |k|
        $redis.del(k)
      end
    end
    # rubocop:enable Rails/SkipsModelValidations

    private

    def key
      @key ||= Digest::SHA256.hexdigest("#{@service}_#{@params.to_s.parameterize}")
    end
  end
end
