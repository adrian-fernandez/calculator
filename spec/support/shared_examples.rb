# frozen_string_literal: true

shared_examples 'unauthenticated request' do |url:|
  let(:error) { 'unauthorized' }
  let(:error_description) { 'You are not authorized to access this resource.' }
  let(:headers) { { 'Authorization' => 'Bearer wrong_token' } }

  before { get(url, headers:) }

  it 'returns 403 error' do
    expect(response).to have_http_status(:unauthorized)
  end

  it 'returns payload with error' do
    expect(JSON.parse(response.body)).to eq({
                                              'error' => error,
                                              'error_description' => error_description
                                            })
  end
end
