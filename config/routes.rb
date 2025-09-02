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
      post "auth/resend_otp", to: "users/otp_resend#resend"

      namespace :super_admin do
        resources :users, only: [ :index, :show ] do
          member do
            patch :update_status
          end
          collection do
            get :metrics
          end
        end
        resources :brands, only: [ :index ]
      end

       # Product Management
      resources :products do
        collection do
          get :search
          get :featured
        end
        resources :reviews, only: [:index, :create, :update, :destroy]
      end

      # Categories
      resources :categories, only: [:index, :show]

      # Brand Owner Routes
      namespace :brand do
        resources :products
        resources :orders, only: [:index, :show] do
          member do
            patch :update_item_status
          end
        end
        resource :profile, only: [:show, :update]
        resources :analytics, only: [:index] do
          collection do
            get :sales
            get :inventory
          end
        end
      end

       # Customer Routes
      namespace :customer do
        resources :orders do
          collection do
            get :history
          end
        end
        resources :cart_items
        resource :profile, only: [:show, :update]
        resources :addresses
        get 'wishlist', to: 'wishlist#index'
      end

      
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
