# frozen_string_literal: true

Doorkeeper::Application.create(name: 'MOQO', uid: SecureRandom.hex(16),
                               secret: SecureRandom.hex(16), redirect_uri: 'http://dummy.net')
User.create(name: 'Sample user')
Doorkeeper::AccessToken.create(
  resource_owner_id: User.first.id,
  application_id: Doorkeeper::Application.first.id,
  token: SecureRandom.hex(64),
  scopes: 'public',
  expires_in: 1.month.to_i
)

# rubocop:disable Rails/Output
puts "Created sample user with token #{Doorkeeper::AccessToken.first.token}"
# rubocop:enable Rails/Output
