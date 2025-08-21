class Api::V1::CategoriesController < ApplicationController
    def index
        categories = Category.includes(:products)
        render json: categories, include: :products
    end

    def show
        category = Category.find(params[:id])
        render json: category, include: :products
    end
end
