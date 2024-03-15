# frozen_string_literal: true

require 'rails_helper'
require 'digest'

describe CacheService, type: :service do
  subject(:call) do
    described_class.call(service: 'DummyService', params: '123', format: :json, api:)
  end

  let(:api) { double }

  before do
    allow(api).to receive(:call).and_return({ value: 'api' })

    $redis.flushall
  end

  describe '#call' do
    context 'when data available on redis' do
      before do
        $redis.set('dummyservice_123', '{"value":"redis"}')
      end

      it 'reads value from redis' do
        expect(call).to eq({ 'value' => 'redis' })
        expect(api).not_to have_received(:call)
      end

      context 'when format is json but value is invalid' do
        before do
          $redis.set('dummyservice_123', 'batman')
        end

        it 'fallbacks to api to fetch the value again' do
          expect(call).to eq({ value: 'api' })

          expect(api).to have_received(:call)
        end
      end
    end

    context 'when data available on DB' do
      let(:key) { Digest::SHA256.hexdigest('DummyService_123') }

      before do
        $redis.set('dummyservice_124', '{"value":"redis"}')
        CachedQuery.create!(key:, value: '{"value":"db"}')
      end

      it 'reads value from db' do
        expect(call).to eq({ 'value' => 'db' })
        expect(api).not_to have_received(:call)
      end
    end

    context 'when data is not available neither Redis nor DB' do
      let(:key) { Digest::SHA256.hexdigest('DummyService_124') }

      before do
        $redis.set('dummyservice_124', '{"value":"redis"}')
        CachedQuery.create!(key:, value: '{"value":"db"}')
      end

      it 'reads value from api' do
        expect($redis.get('dummyservice_123')).to be_nil
        expect(call).to eq({ value: 'api' })
      end

      it 'executes the api call to fetch the result' do
        call

        expect(api).to have_received(:call)
        expect($redis.get('dummyservice_123')).to eq('{"value":"api"}')
      end
    end

    context 'when data is not available neither Redis nor DB and Redis has many keys' do
      let(:key) { Digest::SHA256.hexdigest('DummyService_124') }

      before do
        (1..(ENV.fetch('CACHE_THRESHOLD', 100) + 1)).each do |i|
          $redis.set("dummyservice_#{i}", "{\"value\":\"redis_#{i}\"}")
        end
      end

      it 'calls persister job to save cache on db' do
        expect(DbCacheQueryPersistJob).to receive(:perform_later).with('dummyservice')

        call
      end

      it 'reads value from api and saves it on redis' do
        expect(call).to eq({ value: 'api' })
        expect($redis.get('dummyservice_123')).to eq('{"value":"api"}')
      end
    end
  end
end
