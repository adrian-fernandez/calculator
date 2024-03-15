# frozen_string_literal: true

require 'rails_helper'
require 'digest'

describe Cache::Database, type: :service do
  subject(:persist) { described_class.persist('dummy') }

  before do
    $redis.flushall

    (1..2).each do |i|
      $redis.set("dummy_#{i}", i)
    end
    $redis.set('johndoe_1', 1)
  end

  describe '#persist' do
    it 'creates db records for cached queries and removes them from redis' do
      expect($redis.keys.length).to eq(3)

      expect { persist }.to change(CachedQuery, :count).by(2).and change {
        $redis.keys.length
      }.from(3).to(1)

      expect($redis.get('johndoe_1')).to eq('1')

      expect(CachedQuery.pluck(:value).sort).to match_array(%w[1 2])
    end
  end
end
