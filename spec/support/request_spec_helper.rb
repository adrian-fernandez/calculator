# frozen_string_literal: true

def json_response
  ActiveSupport::HashWithIndifferentAccess.new(
    JSON.parse(response.body)
  )
end
