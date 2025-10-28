class Api::V1::SuperAdmin::UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_super_admin
    before_action :set_user, only: [ :show, :update_status, :update_role ]

    def index
        users = User.includes(:user_role, :brand, :customer)
                    .order(created_at: :desc)
                    .page(params[:page])
                    .per(20)

        # Filter by role if specified
        if params[:role].present?
            role = UserRole.find_by(name: params[:role])
            users = users.where(user_role: role) if role
        end

        # Filter by status if specified
        users = users.where(status: params[:status]) if params[:status].present?

        # Search by email or name
        if params[:search].present?
            search_term = "%#{params[:search]}%"
            users = users.joins("LEFT JOIN brands ON brands.user_id = users.id")
                        .joins("LEFT JOIN customers ON customers.user_id = users.id")
                        .where(
                            "users.email ILIKE ? OR brands.brand_name ILIKE ? OR customers.first_name ILIKE ? OR customers.last_name ILIKE ?",
                            search_term, search_term, search_term, search_term
                        )
        end

        render json: {
            users: users.map { |user| user_summary(user) },
            pagination: pagination_info(users)
        }
    end

    def show
        render json: user_details(@user)
    end

    def by_role
        role_stats = UserRole.joins(:users)
                            .group('user_roles.name')
                            .count('users.id')

        users_by_role = UserRole.includes(users: [:brand, :customer])
                               .map do |role|
            {
                role: role.name,
                count: role.users.count,
                users: role.users.limit(10).map { |user| user_summary(user) }
            }
        end

        render json: {
            role_statistics: role_stats,
            users_by_role: users_by_role
        }
    end

    def flagged
        # Users with potential issues
        flagged_users = {}

        # Multiple recent failed login attempts
        users_with_failed_logins = User.where(
            "failed_attempts > ? AND updated_at > ?", 
            5, 
            1.day.ago
        )

        # Brand owners with no products
        inactive_brands = User.joins(:user_role, :brand)
                             .where(user_roles: { name: 'brand_owner' })
                             .left_joins("LEFT JOIN products ON products.brand_id = brands.id")
                             .where(products: { id: nil })
                             .where('users.created_at < ?', 30.days.ago)

        # Customers with no orders
        inactive_customers = User.joins(:user_role, :customer)
                                .where(user_roles: { name: 'customer' })
                                .left_joins("LEFT JOIN orders ON orders.customer_id = customers.id")
                                .where(orders: { id: nil })
                                .where('users.created_at < ?', 30.days.ago)

        flagged_users = {
            failed_login_attempts: users_with_failed_logins.map { |user| user_summary(user) },
            inactive_brand_owners: inactive_brands.map { |user| user_summary(user) },
            inactive_customers: inactive_customers.map { |user| user_summary(user) }
        }

        render json: flagged_users
    end

    def update_status
        status = params[:status].to_s

        unless User.statuses.key?(status)
            return render json: { error: "Invalid status value" }, status: :unprocessable_entity
        end

        if @user.update(status: status)
            # Log the status change
            Rails.logger.info "Super Admin #{current_user.email} changed user #{@user.email} status to #{status}"
            
            render json: { 
                message: "User status updated successfully", 
                user: user_summary(@user) 
            }
        else
            render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def update_role
        new_role = UserRole.find_by(name: params[:role])
        
        unless new_role
            render json: { error: "Invalid role specified" }, status: :unprocessable_entity
            return
        end

        old_role = @user.user_role.name

        if @user.update(user_role: new_role)
            # Handle role-specific profile creation/deletion
            handle_role_change(@user, old_role, params[:role])
            
            Rails.logger.info "Super Admin #{current_user.email} changed user #{@user.email} role from #{old_role} to #{params[:role]}"
            
            render json: { 
                message: "User role updated successfully", 
                user: user_summary(@user) 
            }
        else
            render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def metrics
        total_users = User.count
        role_breakdown = UserRole.joins(:users).group('user_roles.name').count('users.id')
        
        recent_signups = User.where(created_at: 7.days.ago..Time.current).count
        active_users = User.where(last_sign_in_at: 30.days.ago..Time.current).count
        
        # Brand-specific metrics
        total_brands = User.joins(:user_role).where(user_roles: { name: 'brand_owner' }).count
        active_brands = User.joins(:user_role, :brand)
                           .joins("JOIN products ON products.brand_id = brands.id")
                           .where(user_roles: { name: 'brand_owner' })
                           .distinct.count

        # Customer-specific metrics
        total_customers = User.joins(:user_role).where(user_roles: { name: 'customer' }).count
        customers_with_orders = User.joins(:user_role, :customer)
                                   .joins("JOIN orders ON orders.customer_id = customers.id")
                                   .where(user_roles: { name: 'customer' })
                                   .distinct.count

        render json: {
            overview: {
                total_users: total_users,
                recent_signups: recent_signups,
                active_users: active_users
            },
            role_breakdown: role_breakdown,
            brand_metrics: {
                total_brands: total_brands,
                active_brands: active_brands,
                inactive_brands: total_brands - active_brands
            },
            customer_metrics: {
                total_customers: total_customers,
                customers_with_orders: customers_with_orders,
                customers_without_orders: total_customers - customers_without_orders
            }
        }
    end

  private

    def ensure_super_admin
        unless current_user.user_role.name == "super_admin"
        render json: { error: "You are not authorized to perform this action" }, status: :forbidden
        end
    end

    def set_user
        @user = User.find_by(id: params[:id])
        render json: { error: "User not found" }, status: :not_found unless @user
    end

    def pagination_info(users)
        {
            current_page: users.respond_to?(:current_page) ? users.current_page : 1,
            total_pages: users.respond_to?(:total_pages) ? users.total_pages : 1,
            total_count: users.respond_to?(:total_count) ? users.total_count : users.count
        }
    end

    def user_summary(user)
        {
            id: user.id,
            email: user.email,
            role: user.user_role.name,
            status: user.status,
            created_at: user.created_at,
            last_sign_in_at: user.last_sign_in_at,
            profile: user_profile_info(user)
        }
    end

    def user_details(user)
        {
            id: user.id,
            email: user.email,
            role: user.user_role.name,
            status: user.status,
            created_at: user.created_at,
            updated_at: user.updated_at,
            last_sign_in_at: user.last_sign_in_at,
            sign_in_count: user.sign_in_count,
            failed_attempts: user.failed_attempts,
            profile: detailed_profile_info(user),
            activity_summary: user_activity_summary(user)
        }
    end

    def user_profile_info(user)
        case user.user_role.name
        when 'brand_owner'
            user.brand ? {
                brand_name: user.brand.brand_name,
                brand_description: user.brand.brand_description,
                products_count: user.brand.products.count
            } : nil
        when 'customer'
            user.customer ? {
                full_name: "#{user.customer.first_name} #{user.customer.last_name}",
                phone_number: user.customer.phone_number,
                orders_count: user.customer.orders.count
            } : nil
        else
            nil
        end
    end

    def detailed_profile_info(user)
        case user.user_role.name
        when 'brand_owner'
            if user.brand
                {
                    brand_name: user.brand.brand_name,
                    brand_description: user.brand.brand_description,
                    products_count: user.brand.products.count,
                    total_orders: Order.joins(order_items: :product).where(products: { brand_id: user.brand.id }).count,
                    recent_products: user.brand.products.limit(5).pluck(:name, :price, :created_at)
                }
            end
        when 'customer'
            if user.customer
                {
                    first_name: user.customer.first_name,
                    last_name: user.customer.last_name,
                    phone_number: user.customer.phone_number,
                    orders_count: user.customer.orders.count,
                    total_spent: user.customer.orders.sum(:total_price),
                    recent_orders: user.customer.orders.limit(5).pluck(:id, :total_price, :status, :created_at)
                }
            end
        end
    end

    def user_activity_summary(user)
        case user.user_role.name
        when 'brand_owner'
            {
                products_created_last_30_days: user.brand&.products&.where(created_at: 30.days.ago..Time.current)&.count || 0,
                orders_received_last_30_days: user.brand ? Order.joins(order_items: :product).where(products: { brand_id: user.brand.id }).where(created_at: 30.days.ago..Time.current).count : 0
            }
        when 'customer'
            {
                orders_last_30_days: user.customer&.orders&.where(created_at: 30.days.ago..Time.current)&.count || 0,
                total_spent_last_30_days: user.customer&.orders&.where(created_at: 30.days.ago..Time.current)&.sum(:total_price) || 0
            }
        else
            {}
        end
    end

    def handle_role_change(user, old_role, new_role)
        # Clean up old role-specific data
        case old_role
        when 'brand_owner'
            user.brand&.destroy
        when 'customer'
            user.customer&.destroy
        end

        # Create new role-specific profile if needed
        case new_role
        when 'brand_owner'
            # Brand profile will need to be created separately by the user
        when 'customer'
            user.create_customer(first_name: 'Updated', last_name: 'User')
        end
    end
end
