FactoryBot.define do
  factory :product do
    name { "MyString" }
    description { "MyText" }
    price { "9.99" }
    stock { 1 }
    status { 1 }
    image_url { "MyString" }
    category { nil }
    brand { nil }
  end
end
