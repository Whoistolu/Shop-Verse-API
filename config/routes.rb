Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # Devise routes
      devise_for :users,
        path: "auth",
        controllers: {
          sessions: "api/v1/users/sessions",
          registrations: "api/v1/users/registrations"
        },
        default: { format: :json }

      post "auth/brand_signup", to: "users/registrations#brand_signup"
      post "auth/customer_signup", to: "users/registrations#customer_signup"
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
