class Api::V1::Users::CategoriesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_categroy, only: [ :show, :update, :destroy ]
    skip_before_action :authenticate_user!, only: [ :index ]
    before_action :ensure_super_admin, only: [ :create, :update, :destroy ]
    respond_to :json

    def index
      @categories = Category.all
      render json: @categories, status: :ok
    end

    def show
        if @category
            render json: @category, status: :ok
        else
            render json: { error: "Category not found" }, status: :not_found
        end
    end

    def create
        @category = Category.new(category_params)
        if @category.save
            render json: @category, status: :created
        else
            render json: { error: @category.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def update
        if @category.update(category_params)
            render json: @category, status: :ok
        else
            render json: { error: @category.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def destroy
        if @category&.destroy
            render json: { message: "Category deleted successfully" }, status: :ok
        else
            render json: { error: "Category not found or could not be deleted" }, status: :not_found
        end
    end

    private

    def category_params
      params.require(:category).permit(:name)
    end

    def ensure_super_admin
        unless current_user.user_role.name == "super_admin"
            render json: { error: "You are not authorized to perform this action" }, status: :forbidden
        end
    end

    def set_categroy
        @category = Category.find_by(id: params[:id])
        unless @category
            render json: { error: "Category not found" }, status: :not_found
        end 
    end
end
