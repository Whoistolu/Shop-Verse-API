FactoryBot.define do
  factory :product do
    name { "MyString" }
    description { "MyText" }
    brand { nil }
    category { nil }
    price { "9.99" }
    stock { 1 }
    status { "MyString" }
    image_url { "MyString" }
  end
end
