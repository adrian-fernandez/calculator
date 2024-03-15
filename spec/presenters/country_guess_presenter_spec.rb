# frozen_string_literal: true

require 'rails_helper'

Result = Struct.new(:payload, :valid)

describe CountryGuessPresenter, type: :service do
  subject(:call) do
    described_class.new(object:, requested_name:, time_processed:).call
  end

  let(:requested_name) { '1+1' }
  let(:time_processed) { 0.1 }
  let(:object) { Result.new(result, valid) }

  context 'when the result is valid' do
    let(:valid) { true }
    let(:result) { 'ESP' }

    it do
      expect(call).to eq({
                           guessed_country: result,
                           requested_name:,
                           time_processed:
                         })
    end
  end

  context 'when the result is invalid' do
    let(:valid) { false }
    let(:result) { 'Error' }

    it { is_expected.to eq({ payload: result, valid: false }) }
  end
end
