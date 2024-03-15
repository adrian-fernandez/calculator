# frozen_string_literal: true

require 'rails_helper'

Result = Struct.new(:payload, :valid)

describe CalculatorPresenter, type: :service do
  subject(:call) do
    described_class.new(object:, expression:).call
  end

  let(:expression) { '1+1' }
  let(:object) { Result.new(result, valid) }

  context 'when the result is valid' do
    let(:valid) { true }
    let(:result) { 2 }

    it { is_expected.to eq({ expression:, result: }) }
  end

  context 'when the result is invalid' do
    let(:valid) { false }
    let(:result) { 'Error' }

    it { is_expected.to eq({ payload: result, valid: false }) }
  end
end
