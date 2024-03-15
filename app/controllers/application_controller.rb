# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :doorkeeper_authorize!

  rescue_from Doorkeeper::Errors::DoorkeeperError,
              with: :doorkeeper_unauthorized

  private

  def doorkeeper_unauthorized(_error)
    response_body = {
      error: 'unauthorized',
      error_description: 'You are not authorized to access this resource.'
    }
    render json: response_body, status: :unauthorized
  end
end
