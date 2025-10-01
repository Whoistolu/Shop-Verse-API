roles = [
  { name: "super_admin", description: "Super Admin with all permissions" },
  { name: "brand_owner", description: "Brand owner" },
  { name: "customer", description: "Standard Customer" }
]

roles.each do |role|
  UserRole.find_or_create_by(name: role[:name]) do |r|
    r.description = role[:description]
  end
end

categories = [
  { name: "Appliances" },
  { name: "Phone & Tablets" },
  { name: "Health & Beauty" },
  { name: "Home & Office" },
  { name: "Electronics" },
  { name: "Fashion" },
  { name: "Supermarket" },
  { name: "Computing" },
  { name: "Baby Products" },
  { name: "Gaming" },
  { name: "Musical instruments" },
  { name: "Sports & Fitness" },
  { name: "Automotive & Industrial" },
  { name: "Books & Stationery" },
  { name: "Jewelry & Accessories" },
  { name: "Arts & Crafts" },
  { name: "Pet Supplies" },
  { name: "Garden & Outdoor" },
  { name: "Toys & Games" },
  { name: "Office Supplies" }
]

categories.each do |category|
  Category.find_or_create_by(name: category[:name])
end

super_admin_role = UserRole.find_by(name: "super_admin")
if super_admin_role && !User.exists?(email: "admin@shopverse.com")
  User.create!(
    email: "admin@shopverse.com",
    password: "password123",
    password_confirmation: "password123",
    first_name: "Super",
    last_name: "Admin",
    user_role: super_admin_role,
    status: :approved
  )
  puts "Super admin user created: admin@shopverse.com / password123"
end
