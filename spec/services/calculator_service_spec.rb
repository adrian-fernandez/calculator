# frozen_string_literal: true

require 'rails_helper'

describe CalculatorService, type: :service do
  subject do
    result = described_class.call(data:)

    [result.payload, result.valid]
  end

  describe '#call' do
    context 'when data is valid' do
      let(:data) { '5*3+20-4/2' }

      it { is_expected.to eq([33.0, true]) }
    end

    context 'when data is invalid' do
      let(:data) { '5*3+20/' }

      it { is_expected.to eq([described_class::INVALID_FORMAT, false]) }
    end

    context 'when data is wrong' do
      let(:data) { 'dummy' }

      it { is_expected.to eq([described_class::INVALID_CHARACTERS, false]) }
    end

    context 'when there is a division by zero' do
      let(:data) { '3/0' }

      it { is_expected.to eq([described_class::ZERO_DIVISION, false]) }
    end
  end
end
