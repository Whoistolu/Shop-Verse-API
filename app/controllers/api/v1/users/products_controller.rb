class Api::V1::ProductController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_brand_owner, only: [ :create, :index ]
    before_action :set_product, only: [ :update, :destroy ]
    respond_to :json

    def index
       @products = current_user.brand.products
    end

    def create
        @product = current_user.brand.products.new(product_params)
    end

    def update
        @product = current_user.brand.products.find(params[:id])
        if @product.update(product_params)
            render json: { message: "Product updated successfully" }, status: :ok
        else
            render json: { error: @product.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def destroy
        @product = current_user.brand.products.find(params[:id])
        if @product.destroy
            render json: { message: "Product deleted successfully" }, status: :ok
        else
            render json: { error: @product.errors.full_messages }, status: :unprocessable_entity
        end
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

    def set_product
        @product = current_user.brand.products.find_by(id: params[:id])
        render json: { error: "Product not found" }, status: :not_found unless @product
    end
end
