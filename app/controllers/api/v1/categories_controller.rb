class Api::V1::CategoriesController < ApplicationController
    def index
        categories = Category.includes(:products)
        render json: categories, include: :products
    end
end
