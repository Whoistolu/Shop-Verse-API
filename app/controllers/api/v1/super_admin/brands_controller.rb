class Api::V1::SuperAdmin::BrandsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_super_admin
    before_action :set_brand, only: [:show, :update_status]
    respond_to :json

    def index
        brands = Brand.includes(:user, :products)
                     .order(created_at: :desc)
                     .page(params[:page])
                     .per(20)

        # Filter by status if specified
        brands = brands.joins(:user).where(users: { status: params[:status] }) if params[:status].present?

        # Search by brand name or owner email
        if params[:search].present?
            search_term = "%#{params[:search]}%"
            brands = brands.joins(:user)
                          .where(
                              "brands.name ILIKE ? OR users.email ILIKE ?",
                              search_term, search_term
                          )
        end

        # Filter by activity level
        case params[:activity]
        when 'active'
            brands = brands.joins(:products).distinct
        when 'inactive'
            brands = brands.left_joins(:products).where(products: { id: nil })
        end

        # Filter by performance
        case params[:performance]
        when 'high'
            brands = brands.select { |brand| brand.total_orders > 10 }
        when 'low'
            brands = brands.select { |brand| brand.total_orders <= 5 }
        end

        render json: {
            brands: brands.map { |brand| brand_summary(brand) },
            pagination: pagination_info(brands),
            statistics: brand_statistics
        }
    end

    def show
        render json: brand_details(@brand)
    end

    def metrics
        total_brands = Brand.count
        active_brands = Brand.joins(:products).distinct.count
        inactive_brands = total_brands - active_brands
        
        recent_brands = Brand.where(created_at: 7.days.ago..Time.current).count
        
        # Performance metrics
        high_performing = Brand.all.select { |b| b.total_orders > 10 }.count
        low_performing = Brand.all.select { |b| b.total_orders <= 5 }.count
        
        # Revenue metrics
        total_revenue = Brand.all.sum(&:total_sales)
        avg_revenue_per_brand = total_brands > 0 ? total_revenue / total_brands : 0

        render json: {
            overview: {
                total_brands: total_brands,
                active_brands: active_brands,
                inactive_brands: inactive_brands,
                recent_brands: recent_brands
            },
            performance: {
                high_performing: high_performing,
                medium_performing: total_brands - high_performing - low_performing,
                low_performing: low_performing
            },
            revenue: {
                total_revenue: total_revenue,
                average_per_brand: avg_revenue_per_brand
            },
            top_brands: top_performing_brands(5)
        }
    end

    def flagged
        # Brands that might need attention
        flagged_brands = {}

        # Brands with no products after 30 days
        inactive_brands = Brand.left_joins(:products)
                              .where(products: { id: nil })
                              .where('brands.created_at < ?', 30.days.ago)

        # Brands with very low performance
        low_performing_brands = Brand.all.select do |brand| 
            brand.created_at < 60.days.ago && brand.total_orders < 3
        end

        # Brands with suspended owners
        suspended_owners = Brand.joins(:user)
                               .where(users: { status: 'suspended' })

        flagged_brands = {
            inactive_brands: inactive_brands.map { |brand| brand_summary(brand) },
            low_performing: low_performing_brands.map { |brand| brand_summary(brand) },
            suspended_owners: suspended_owners.map { |brand| brand_summary(brand) }
        }

        render json: flagged_brands
    end

    def update_status
        user = @brand.user
        status = params[:status].to_s

        unless User.statuses.key?(status)
            return render json: { error: "Invalid status value" }, status: :unprocessable_entity
        end

        if user.update(status: status)
            # Log the status change
            Rails.logger.info "Super Admin #{current_user.email} changed brand #{@brand.name} owner status to #{status}"
            
            render json: { 
                message: "Brand owner status updated successfully", 
                brand: brand_summary(@brand) 
            }
        else
            render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
    end

    private

    def ensure_super_admin
        unless current_user.user_role.name == "super_admin"
            render json: { error: "You are not authorized to perform this action" }, status: :forbidden
        end
    end

    def set_brand
        @brand = Brand.find_by(id: params[:id])
        render json: { error: "Brand not found" }, status: :not_found unless @brand
    end

    def pagination_info(brands)
        {
            current_page: brands.respond_to?(:current_page) ? brands.current_page : 1,
            total_pages: brands.respond_to?(:total_pages) ? brands.total_pages : 1,
            total_count: brands.respond_to?(:total_count) ? brands.total_count : brands.count
        }
    end

    def brand_summary(brand)
        {
            id: brand.id,
            name: brand.name,
            description: brand.description,
            owner_email: brand.user.email,
            owner_status: brand.user.status,
            products_count: brand.products.count,
            total_orders: brand.total_orders,
            total_sales: brand.total_sales,
            created_at: brand.created_at,
            last_activity: brand.products.maximum(:updated_at) || brand.created_at,
            performance_rating: calculate_performance_rating(brand)
        }
    end

    def brand_details(brand)
        {
            id: brand.id,
            name: brand.name,
            description: brand.description,
            owner: {
                id: brand.user.id,
                email: brand.user.email,
                first_name: brand.user.first_name,
                last_name: brand.user.last_name,
                status: brand.user.status,
                last_sign_in_at: brand.user.last_sign_in_at
            },
            statistics: {
                products_count: brand.products.count,
                total_orders: brand.total_orders,
                total_sales: brand.total_sales,
                average_order_value: brand.total_orders > 0 ? brand.total_sales / brand.total_orders : 0
            },
            recent_activity: {
                recent_products: brand.products.order(created_at: :desc).limit(5).pluck(:name, :price, :created_at),
                recent_orders: brand.recent_orders.pluck(:id, :total_price, :status, :created_at)
            },
            top_products: brand.top_selling_products.pluck(:name, :price),
            created_at: brand.created_at,
            updated_at: brand.updated_at
        }
    end

    def brand_statistics
        total_brands = Brand.count
        {
            total_count: total_brands,
            with_products: Brand.joins(:products).distinct.count,
            without_products: Brand.left_joins(:products).where(products: { id: nil }).count,
            active_last_30_days: Brand.joins(:products).where(products: { created_at: 30.days.ago..Time.current }).distinct.count
        }
    end

    def top_performing_brands(limit)
        Brand.all.sort_by(&:total_sales).reverse.first(limit).map do |brand|
            {
                id: brand.id,
                name: brand.name,
                total_sales: brand.total_sales,
                total_orders: brand.total_orders,
                products_count: brand.products.count
            }
        end
    end

    def calculate_performance_rating(brand)
        orders = brand.total_orders
        sales = brand.total_sales
        products = brand.products.count
        age_in_days = (Time.current - brand.created_at).to_i / 1.day

        # Simple performance scoring
        score = 0
        score += orders * 2
        score += (sales / 1000).to_i
        score += products * 5
        score -= age_in_days / 30 if age_in_days > 90 # Penalty for old inactive brands

        case score
        when 0..20 then 'Low'
        when 21..50 then 'Medium'
        when 51..100 then 'High'
        else 'Excellent'
        end
    end
end
