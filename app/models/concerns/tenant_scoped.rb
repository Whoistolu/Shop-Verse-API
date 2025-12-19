module TenantScoped
  extend ActiveSupport::Concern

  included do
    belongs_to :brand

    default_scope do
      if Current.user&.super_admin?
        all
      elsif Current.brand
        where(brand_id: Current.brand.id)
      else
        none
      end
    end
  end
end
