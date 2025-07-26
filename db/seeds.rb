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
