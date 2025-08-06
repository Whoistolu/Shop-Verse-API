class Api::V1::ProductController < ApplicationController
    before_action :ensure_brand_owner, only: [ :create, :index ]

    def index
       @products = current_user.brand.products
    end


    def create
        @product = current_user.brand.products.new(product_params)
    end

    private

    def product_params
         params.require(:product).permit(:name, :description, :price, :category_id, :brand_id, :status, :stock, :status, :image_url)
    end

    def ensure_brand_owner
        unless current_user.user_role.name == "brand_owner"
            render json: { error: "You are not authorized to perform this action" }, status: :forbidden
        end
    end
end
