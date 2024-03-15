# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Services Request' do
  include_context 'with authenticated user'

  describe 'GET /api/v1/services/calc' do
    it_behaves_like 'unauthenticated request', url: '/api/v1/services/calc?expression=1+1'

    context 'when user is authenticated' do
      before do
        get "/api/v1/services/calc?expression=#{params}", headers:
      end

      context 'when the request is valid' do
        let(:params) { '5+10*5/2' }

        it 'returns the result and the status' do
          expect(response).to have_http_status(:ok)
          expect(json_response['expression']).to eq('5+10*5/2')
          expect(json_response['result']).to eq(30) # 5 + 50 / 2 = 5 + 25 = 30
        end
      end

      context 'when the request contains unsupported characters' do
        let(:params) { '5+10*5/2.' }

        it 'returns the result and the status' do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['payload']).to eq(CalculatorService::INVALID_CHARACTERS)
          expect(json_response['valid']).to be(false)
        end
      end

      context 'when the request contains wrong expression' do
        let(:params) { '5+' }

        it 'returns the result and the status' do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['payload']).to eq(CalculatorService::INVALID_FORMAT)
          expect(json_response['valid']).to be(false)
        end
      end

      context 'when the request contains empty expression' do
        let(:params) { '   ' }

        it 'returns the result and the status' do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['payload']).to eq(CalculatorService::INVALID_FORMAT)
          expect(json_response['valid']).to be(false)
        end
      end
    end
  end

  describe 'GET /api/v1/services/country_guess' do
    it_behaves_like 'unauthenticated request', url: '/api/v1/services/country_guess?name=Doe'

    context 'when user is authenticated' do
      before do
        $redis.flushall
      end

      context 'when the request is valid' do
        let(:surname) { 'Fernandez' }

        it 'returns the result and the status' do
          VCR.use_cassette('country_valid') do
            get("/api/v1/services/country_guess?name=#{surname}", headers:)

            expect(response).to have_http_status(:ok)
            expect(json_response['guessed_country']).to eq('ESP')
            expect(json_response['requested_name']).to eq('Fernandez')
            expect(json_response['time_processed']).to be_a(Float)
          end
        end
      end

      context 'when the API provider returns unexpected data' do
        let(:surname) { 'dummy' }

        it 'returns the result and the status' do
          VCR.use_cassette('country_invalid') do
            get("/api/v1/services/country_guess?name=#{surname}", headers:)

            expect(response).to have_http_status(:unprocessable_entity)
            expect(json_response['payload']).to eq(Api::FamilySearch::ERROR_TXT)
            expect(json_response['valid']).to be(false)
          end
        end
      end

      context 'when the API provider fails' do
        let(:surname) { 'dummy' }
        let(:error) { 'Simulated error' }
        let(:expected_result) { "#{Api::FamilySearch::ERROR_TXT}: #{error}" }

        it 'returns the result and the status' do
          allow(Faraday).to receive(:get).and_raise(Faraday::Error.new(error))

          get("/api/v1/services/country_guess?name=#{surname}", headers:)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['payload']).to eq(expected_result)
          expect(json_response['valid']).to be(false)
        end
      end
    end
  end
end
