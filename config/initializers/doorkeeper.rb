# frozen_string_literal: true

Doorkeeper.configure do
  orm :active_record

  # This block will be called to check whether the resource owner is authenticated or not.
  resource_owner_authenticator do
    User.find_by(id: session[:user_id])
  end

  skip_authorization do
    true
  end

  api_only

  access_token_expires_in 1.week
  base_controller 'ApplicationController'
  grant_flows %w[authorization_code implicit password client_credentials]

  use_refresh_token
  reuse_access_token

  enable_application_owner confirmation: false

  default_scopes :public
  access_token_methods :from_bearer_authorization

  handle_auth_errors :raise
end
