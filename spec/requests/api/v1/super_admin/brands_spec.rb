require 'rails_helper'

RSpec.describe "Api::V1::SuperAdmin::Brands", type: :request do
  let(:super_admin_role) { create(:user_role, name: 'super_admin') }
  let(:brand_owner_role) { create(:user_role, name: 'brand_owner') }
  
  let(:super_admin) { create(:user, user_role: super_admin_role) }
  let(:brand_owner) { create(:user, user_role: brand_owner_role) }
  let(:brand) { create(:brand, user: brand_owner) }

  before do
    # Mock JWT authentication for super admin
    allow_any_instance_of(Api::V1::SuperAdmin::BrandsController).to receive(:authenticate_user!).and_return(true)
    allow_any_instance_of(Api::V1::SuperAdmin::BrandsController).to receive(:current_user).and_return(super_admin)
  end

  describe "GET /api/v1/super_admin/brands" do
    before do
      brand
    end

    it "returns all brands with pagination and statistics" do
      get "/api/v1/super_admin/brands"
      
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)
      expect(data).to have_key('brands')
      expect(data).to have_key('pagination')
      expect(data).to have_key('statistics')
    end

    it "filters brands by search term" do
      get "/api/v1/super_admin/brands", params: { search: brand.name }
      
      expect(response).to have_http_status(:success)
      brands = JSON.parse(response.body)['brands']
      expect(brands.any? { |b| b['name'] == brand.name }).to be_truthy
    end

    it "filters brands by activity level" do
      get "/api/v1/super_admin/brands", params: { activity: 'inactive' }
      
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)
      expect(data).to have_key('brands')
    end

    it "includes brand summary information" do
      get "/api/v1/super_admin/brands"
      
      expect(response).to have_http_status(:success)
      brands = JSON.parse(response.body)['brands']
      brand_data = brands.first
      
      expect(brand_data).to have_key('id')
      expect(brand_data).to have_key('name')
      expect(brand_data).to have_key('owner_email')
      expect(brand_data).to have_key('products_count')
      expect(brand_data).to have_key('total_orders')
      expect(brand_data).to have_key('performance_rating')
    end
  end

  describe "GET /api/v1/super_admin/brands/:id" do
    it "returns detailed brand information" do
      get "/api/v1/super_admin/brands/#{brand.id}"
      
      expect(response).to have_http_status(:success)
      brand_data = JSON.parse(response.body)
      
      expect(brand_data['id']).to eq(brand.id)
      expect(brand_data['name']).to eq(brand.name)
      expect(brand_data).to have_key('owner')
      expect(brand_data).to have_key('statistics')
      expect(brand_data).to have_key('recent_activity')
    end

    it "returns 404 for non-existent brand" do
      get "/api/v1/super_admin/brands/999999"
      
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /api/v1/super_admin/brands/metrics" do
    before do
      brand
    end

    it "returns comprehensive brand metrics" do
      get "/api/v1/super_admin/brands/metrics"
      
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)
      
      expect(data).to have_key('overview')
      expect(data).to have_key('performance')
      expect(data).to have_key('revenue')
      expect(data).to have_key('top_brands')
      
      expect(data['overview']).to have_key('total_brands')
      expect(data['overview']).to have_key('active_brands')
      expect(data['overview']).to have_key('inactive_brands')
    end
  end

  describe "GET /api/v1/super_admin/brands/flagged" do
    it "returns flagged brands that need attention" do
      get "/api/v1/super_admin/brands/flagged"
      
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)
      
      expect(data).to have_key('inactive_brands')
      expect(data).to have_key('low_performing')
      expect(data).to have_key('suspended_owners')
    end
  end

  describe "PATCH /api/v1/super_admin/brands/:id/activate" do
    it "activates a brand successfully" do
      brand.update!(status: 'pending')
      
      patch "/api/v1/super_admin/brands/#{brand.id}/activate"
      
      expect(response).to have_http_status(:success)
      expect(brand.reload.status).to eq('active')
      expect(brand.activated_at).to be_present
      expect(brand.status_changed_by).to eq(super_admin)
    end

    it "includes status history in response" do
      brand.update!(status: 'pending')
      
      patch "/api/v1/super_admin/brands/#{brand.id}/activate"
      
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)
      expect(data).to have_key('status_history')
      expect(data['brand']['status']).to eq('active')
    end
  end

  describe "PATCH /api/v1/super_admin/brands/:id/deactivate" do
    it "deactivates a brand successfully" do
      brand.update!(status: 'active')
      
      patch "/api/v1/super_admin/brands/#{brand.id}/deactivate", 
            params: { reason: 'Policy violation' }
      
      expect(response).to have_http_status(:success)
      expect(brand.reload.status).to eq('deactivated')
      expect(brand.deactivated_at).to be_present
      expect(brand.status_changed_by).to eq(super_admin)
    end

    it "includes reason in response" do
      brand.update!(status: 'active')
      reason = 'Policy violation'
      
      patch "/api/v1/super_admin/brands/#{brand.id}/deactivate", 
            params: { reason: reason }
      
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)
      expect(data['reason']).to eq(reason)
    end
  end

  describe "PATCH /api/v1/super_admin/brands/:id/suspend" do
    it "suspends a brand successfully" do
      brand.update!(status: 'active')
      
      patch "/api/v1/super_admin/brands/#{brand.id}/suspend", 
            params: { reason: 'Under investigation' }
      
      expect(response).to have_http_status(:success)
      expect(brand.reload.status).to eq('suspended')
      expect(brand.deactivated_at).to be_present
      expect(brand.status_changed_by).to eq(super_admin)
    end
  end

  describe "PATCH /api/v1/super_admin/brands/bulk_action" do
    let(:brand2) { create(:brand, user: create(:user, user_role: brand_owner_role)) }
    
    before do
      brand.update!(status: 'pending')
      brand2.update!(status: 'pending')
    end

    it "performs bulk activation successfully" do
      patch "/api/v1/super_admin/brands/bulk_action", 
            params: { 
              brand_ids: [brand.id, brand2.id], 
              action: 'activate' 
            }
      
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)
      
      expect(data['results']['success'].count).to eq(2)
      expect(data['results']['failed'].count).to eq(0)
      expect(brand.reload.status).to eq('active')
      expect(brand2.reload.status).to eq('active')
    end

    it "handles mixed success/failure in bulk action" do
      # Make one brand invalid for activation
      allow_any_instance_of(Brand).to receive(:activate!).and_raise(StandardError, "Test error")
      
      patch "/api/v1/super_admin/brands/bulk_action", 
            params: { 
              brand_ids: [brand.id], 
              action: 'activate' 
            }
      
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)
      expect(data['results']['failed'].count).to eq(1)
    end

    it "returns error for invalid bulk action" do
      patch "/api/v1/super_admin/brands/bulk_action", 
            params: { 
              brand_ids: [brand.id], 
              action: 'invalid_action' 
            }
      
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  context "when user is not super admin" do
    let(:regular_user) { create(:user, user_role: brand_owner_role) }

    before do
      allow_any_instance_of(Api::V1::SuperAdmin::BrandsController).to receive(:current_user).and_return(regular_user)
    end

    it "denies access to brands index" do
      get "/api/v1/super_admin/brands"
      expect(response).to have_http_status(:forbidden)
    end

    it "denies access to brand details" do
      get "/api/v1/super_admin/brands/#{brand.id}"
      expect(response).to have_http_status(:forbidden)
    end

    it "denies access to metrics" do
      get "/api/v1/super_admin/brands/metrics"
      expect(response).to have_http_status(:forbidden)
    end

    it "denies access to status updates" do
      patch "/api/v1/super_admin/brands/#{brand.id}/update_status", 
            params: { status: 'suspended' }
      expect(response).to have_http_status(:forbidden)
    end
  end
end
