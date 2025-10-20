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

brand_owner_role = UserRole.find_by(name: "brand_owner")
if brand_owner_role
  brand_owners = [
    { email: "techhub@shopverse.com", first_name: "John", last_name: "Tech", brand_name: "TechHub", brand_description: "Leading technology brand" },
    { email: "fashion@shopverse.com", first_name: "Sarah", last_name: "Style", brand_name: "FashionForward", brand_description: "Trendy fashion and accessories" },
    { email: "home@shopverse.com", first_name: "Mike", last_name: "Home", brand_name: "HomeEssentials", brand_description: "Quality home and office products" },
    { email: "beauty@shopverse.com", first_name: "Emma", last_name: "Glow", brand_name: "BeautyGlow", brand_description: "Premium beauty and health products" },
    { email: "sport@shopverse.com", first_name: "Alex", last_name: "Fit", brand_name: "SportFit", brand_description: "Sports and fitness equipment" }
  ]

  brand_owners.each do |owner_data|
    unless User.exists?(email: owner_data[:email])
      user = User.create!(
        email: owner_data[:email],
        password: "password123",
        password_confirmation: "password123",
        first_name: owner_data[:first_name],
        last_name: owner_data[:last_name],
        user_role: brand_owner_role,
        status: :approved
      )

      brand = Brand.create!(
        name: owner_data[:brand_name],
        description: owner_data[:brand_description],
        user: user
      )
      puts "Brand owner created: #{owner_data[:email]} for #{owner_data[:brand_name]}"
    end
  end
end

products = [
  # TechHub products
  {
    name: "Wireless Bluetooth Headphones",
    description: "High-quality wireless headphones with noise cancellation and 30-hour battery life",
    price: 199.99,
    stock_quantity: 50,
    brand_name: "TechHub",
    category_name: "Electronics",
    image_url: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400",
    status: "published"
  },
  {
    name: "Smartphone 128GB",
    description: "Latest smartphone with advanced camera and fast processor",
    price: 699.99,
    stock_quantity: 30,
    brand_name: "TechHub",
    category_name: "Phone & Tablets",
    image_url: "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400",
    status: "published"
  },
  {
    name: "Gaming Laptop",
    description: "Powerful gaming laptop with RTX graphics and 16GB RAM",
    price: 1299.99,
    stock_quantity: 15,
    brand_name: "TechHub",
    category_name: "Computing",
    image_url: "https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=400",
    status: "published"
  },

  # Fashion products
  {
    name: "Designer Handbag",
    description: "Elegant leather handbag perfect for any occasion",
    price: 299.99,
    stock_quantity: 25,
    brand_name: "FashionForward",
    category_name: "Fashion",
    image_url: "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400",
    status: "published"
  },
  {
    name: "Running Shoes",
    description: "Comfortable running shoes with advanced cushioning technology",
    price: 149.99,
    stock_quantity: 40,
    brand_name: "FashionForward",
    category_name: "Sports & Fitness",
    image_url: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400",
    status: "published"
  },
  {
    name: "Gold Necklace",
    description: "Beautiful 18k gold necklace with diamond accents",
    price: 499.99,
    stock_quantity: 10,
    brand_name: "FashionForward",
    category_name: "Jewelry & Accessories",
    image_url: "https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=400",
    status: "published"
  },

  # HomeEssentials products
  {
    name: "Coffee Maker",
    description: "Programmable coffee maker with thermal carafe",
    price: 89.99,
    stock_quantity: 35,
    brand_name: "HomeEssentials",
    category_name: "Appliances",
    image_url: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400",
    status: "published"
  },
  {
    name: "Office Chair",
    description: "Ergonomic office chair with lumbar support",
    price: 249.99,
    stock_quantity: 20,
    brand_name: "HomeEssentials",
    category_name: "Home & Office",
    image_url: "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400",
    status: "published"
  },
  {
    name: "Blender",
    description: "High-power blender perfect for smoothies and soups",
    price: 79.99,
    stock_quantity: 28,
    brand_name: "HomeEssentials",
    category_name: "Appliances",
    image_url: "https://images.unsplash.com/photo-1570222094114-d054a817e56b?w=400",
    status: "published"
  },

  # BeautyGlow products
  {
    name: "Facial Cleanser",
    description: "Gentle facial cleanser for all skin types",
    price: 24.99,
    stock_quantity: 60,
    brand_name: "BeautyGlow",
    category_name: "Health & Beauty",
    image_url: "https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400",
    status: "published"
  },
  {
    name: "Hair Dryer",
    description: "Professional hair dryer with multiple heat settings",
    price: 69.99,
    stock_quantity: 22,
    brand_name: "BeautyGlow",
    category_name: "Health & Beauty",
    image_url: "https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400",
    status: "published"
  },

  # Sport products
  {
    name: "Yoga Mat",
    description: "Non-slip yoga mat with carrying strap",
    price: 39.99,
    stock_quantity: 45,
    brand_name: "SportFit",
    category_name: "Sports & Fitness",
    image_url: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400",
    status: "published"
  },
  {
    name: "Dumbbell Set",
    description: "Adjustable dumbbell set from 5-50 lbs",
    price: 199.99,
    stock_quantity: 12,
    brand_name: "SportFit",
    category_name: "Sports & Fitness",
    image_url: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400",
    status: "published"
  },

  # Additional TechHub products
  {
    name: "Wireless Mouse",
    description: "Ergonomic wireless mouse with precision tracking",
    price: 49.99,
    stock_quantity: 75,
    brand_name: "TechHub",
    category_name: "Computing",
    image_url: "https://images.unsplash.com/photo-1527814050087-3793815479db?w=400",
    status: "published"
  },
  {
    name: "USB-C Hub",
    description: "Multi-port USB-C hub with HDMI and USB ports",
    price: 79.99,
    stock_quantity: 40,
    brand_name: "TechHub",
    category_name: "Electronics",
    image_url: "https://images.unsplash.com/photo-1625842268584-8f3296236761?w=400",
    status: "published"
  },
  {
    name: "Smart Watch",
    description: "Fitness tracking smartwatch with heart rate monitor",
    price: 299.99,
    stock_quantity: 25,
    brand_name: "TechHub",
    category_name: "Electronics",
    image_url: "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400",
    status: "published"
  },

  # Additional Fashion products
  {
    name: "Leather Wallet",
    description: "Genuine leather wallet with RFID protection",
    price: 89.99,
    stock_quantity: 50,
    brand_name: "FashionForward",
    category_name: "Fashion",
    image_url: "https://images.unsplash.com/photo-1627123424574-724758594e93?w=400",
    status: "published"
  },
  {
    name: "Sunglasses",
    description: "UV protection sunglasses with polarized lenses",
    price: 129.99,
    stock_quantity: 35,
    brand_name: "FashionForward",
    category_name: "Fashion",
    image_url: "https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=400",
    status: "published"
  },

  # Additional HomeEssentials products
  {
    name: "Air Fryer",
    description: "Healthy cooking air fryer with digital controls",
    price: 149.99,
    stock_quantity: 18,
    brand_name: "HomeEssentials",
    category_name: "Appliances",
    image_url: "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400",
    status: "published"
  },
  {
    name: "Desk Lamp",
    description: "LED desk lamp with adjustable brightness",
    price: 59.99,
    stock_quantity: 30,
    brand_name: "HomeEssentials",
    category_name: "Home & Office",
    image_url: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400",
    status: "published"
  },

  # Additional BeautyGlow products
  {
    name: "Moisturizing Cream",
    description: "Hydrating face cream for daily use",
    price: 34.99,
    stock_quantity: 45,
    brand_name: "BeautyGlow",
    category_name: "Health & Beauty",
    image_url: "https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400",
    status: "published"
  },
  {
    name: "Makeup Brush Set",
    description: "Professional makeup brush set with 12 pieces",
    price: 79.99,
    stock_quantity: 20,
    brand_name: "BeautyGlow",
    category_name: "Health & Beauty",
    image_url: "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=400",
    status: "published"
  },

  # Additional Sport products
  {
    name: "Resistance Bands",
    description: "Set of 5 resistance bands for home workouts",
    price: 29.99,
    stock_quantity: 60,
    brand_name: "SportFit",
    category_name: "Sports & Fitness",
    image_url: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400",
    status: "published"
  },
  {
    name: "Water Bottle",
    description: "Insulated stainless steel water bottle",
    price: 24.99,
    stock_quantity: 80,
    brand_name: "SportFit",
    category_name: "Sports & Fitness",
    image_url: "https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400",
    status: "published"
  }
]

products.each do |product_data|
  brand = Brand.find_by(name: product_data[:brand_name])
  category = Category.find_by(name: product_data[:category_name])

  if brand && category && !Product.exists?(name: product_data[:name])
    Product.create!(
      name: product_data[:name],
      description: product_data[:description],
      price: product_data[:price],
    stock: product_data[:stock_quantity],
      brand: brand,
      category: category,
      image_url: product_data[:image_url],
      status: product_data[:status]
    )
    puts "Product created: #{product_data[:name]}"
  end
end

puts "Seeding completed! Created #{Brand.count} brands, #{User.where(user_role: brand_owner_role).count} brand owners, and #{Product.count} products."
