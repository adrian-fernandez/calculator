# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DbCacheQueryPersistJob do
  include ActiveJob::TestHelper

  it 'gets enqueued' do
    expect do
      described_class.perform_later('dummy')
    end.to have_enqueued_job(described_class)
  end

  it 'runs the task' do
    expect(Cache::Database).to receive(:persist).with('dummy')

    perform_enqueued_jobs { described_class.perform_later('dummy') }
  end
end
