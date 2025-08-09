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

    def create
        @category = Category.new(categories_params)
        if @category.save
            render json: @category, status: :created
        else
            render json: { error: @category.errors.full_messages }, status: :unprocessable_entity
        end
    end



    private

    def category_params
      params.require(:category).permit(:name)
    end
end
