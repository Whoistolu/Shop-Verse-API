Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      devise_for :users,
        path: "auth",
        controllers: {
          sessions: "api/v1/users/sessions"
        },
        defaults: { format: :json },
        skip: [ :sessions ]

      post "auth/brand_signup", to: "users/custom_registrations#brand_signup"
      post "auth/customer_signup", to: "users/custom_registrations#customer_signup"

      post "auth/brand_login", to: "users/custom_sessions#brand_login"
      post "auth/customer_login", to: "users/custom_sessions#customer_login"
      post "auth/super_admin_login", to: "users/custom_sessions#super_admin_login"

      post "auth/verify_otp", to: "users/otp_verification#verify_otp"
      post "auth/resend_otp", to: "users/otp_resend#resend"

      # Public product browsing
      resources :products, only: [ :index, :show ]
      resources :categories, only: [ :index, :show ]

      # Brand owner dashboard and order management (must come before brands resources)
      get "brands/dashboard", to: "brands#dashboard"
      get "brands/orders", to: "brands#orders"
      patch "brands/:id/update_order_status", to: "brands#update_order_status"

      resources :brands, only: [ :index, :show ]

      # Customer cart management
      resources :carts, only: [ :show ] do
        collection do
          post :add_item
          patch :update_item
          delete :remove_item
          delete :clear
        end
      end

      # Customer orders
      resources :orders, only: [ :index, :show, :create ] do
        member do
          patch :update_status
        end
      end

      # Brand owner product management
      resources :products, only: [ :create, :update, :destroy ] do
        collection do
          get :brand_products
        end
        member do
          patch :update_stock
          patch :update_status
        end
      end


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
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
