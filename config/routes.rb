# frozen_string_literal: true

Rails.application.routes.draw do
  use_doorkeeper

  get 'up' => 'rails/health#show', as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :services, only: [] do
        collection do
          get :calc
          get :country_guess
        end
      end
    end
  end
end
