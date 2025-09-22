class Api::V1::CategoriesController < ApplicationController
    skip_before_action :authenticate_user!, only: [:index, :show]
    
    def index
        categories = Category.includes(:products)
        render json: categories, include: :products
    end

    def show
        category = Category.find(params[:id])
        render json: category, include: :products
    end
end
