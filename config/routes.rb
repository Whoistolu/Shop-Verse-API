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

      # Public product browsing
      resources :products, only: [:index, :show]
      resources :categories, only: [:index, :show]
      resources :brands, only: [:index, :show]

      # Customer cart management
      resources :carts, only: [:show] do
        collection do
          post :add_item
          patch :update_item
          delete :remove_item
          delete :clear
        end
      end

      # Customer orders
      resources :orders, only: [:index, :show, :create] do
        member do
          patch :update_status
        end
      end

      # Brand owner product management
      resources :products, only: [:create, :update, :destroy] do
        collection do
          get :brand_products
        end
        member do
          patch :update_stock
          patch :update_status
        end
      end

      # Brand owner dashboard and order management
      resources :brands, only: [] do
        collection do
          get :dashboard
          get :orders
        end
        member do
          patch :update_order_status
        end
      end

      namespace :super_admin do
        resources :users, only: [:index, :show] do
          member do
            patch :update_status
          end
          collection do
            get :metrics
          end
        end
        resources :brands, only: [:index]
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
