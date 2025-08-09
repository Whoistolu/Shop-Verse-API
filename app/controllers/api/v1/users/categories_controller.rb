class Api::V1::Users::CategoriesController < ApplicationController
    def index
      @categories = Category.all
      render json: @categories, status: :ok
    end

    def show
        @category = Category.find_by(id: params[:id])
        if @category
            render json: @category, status: :ok
        else
            render json: { error: "Category not found" }, status: :not_found
        end
    end
end
