# frozen_string_literal: true

class DbCacheQueryPersistJob < ApplicationJob
  queue_as :default

  def perform(key)
    Cache::Database.persist(key)
  end
end
