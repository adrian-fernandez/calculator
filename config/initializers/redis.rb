# frozen_string_literal: true

# $redis = Redis.new(url: ENV["REDIS_URL"])

require 'redis'

$redis = Redis.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379'))
