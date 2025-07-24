Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
        devise_for :users,
          path: "auth",
          controllers: {
            sessions: "api/v1/users/sessions",
            registrations: "api/v1/users/registrations"
          },
          default: { format: :json }
    end
  end
  get "up" => "rails/health#show", as: :rails_health_check
end
