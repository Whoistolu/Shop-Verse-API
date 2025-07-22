# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

UserRole.create(name: "super_admin", description: "Super Admin with all permissions")
UserRole.create(name: "admin", description: "Brand owner")
UserRole.create(name: "customer", description: "Standard Customer")
UserRole.create(name: "guest", description: "Guest User with limited access")
