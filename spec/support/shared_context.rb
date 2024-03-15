# frozen_string_literal: true

RSpec.shared_context 'with authenticated user' do
  let(:application) { create(:application) }
  let(:user) { create(:user) }
  let(:token) do
    create(
      :access_token,
      application:,
      resource_owner_id: user.id,
      scopes: 'public'
    )
  end
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }
end
