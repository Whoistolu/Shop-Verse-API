class Api::V1::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_context

  private

  def set_current_context
    Current.user = current_user

    if current_user.super_admin?
      Current.brand = nil
    elsif current_user.brand_owner?
      Current.brand = current_user.brand
    elsif current_user.customer?
      Current.brand = Brand.find(params[:brand_id])
    end
  end
end
