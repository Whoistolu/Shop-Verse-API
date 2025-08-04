Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

      devise_for :users,
        path: "auth",
        controllers: {
          sessions: "api/v1/users/sessions"
        },
        defaults: { format: :json }

      post "auth/brand_signup", to: "users/custom_registrations#brand_signup"
      post "auth/customer_signup", to: "users/custom_registrations#customer_signup"

      post "auth/brand_login", to: "users/custom_sessions#brand_login"
      post "auth/customer_login", to: "users/custom_sessions#customer_login"

      post "auth/verify_otp", to: "users/otp_verification#verify_otp"
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
