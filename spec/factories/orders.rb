FactoryBot.define do
  factory :order do
    total_price { "9.99" }
    status { 1 }
    delivery_address { "MyText" }
    delivery_phone_number { "MyString" }
    delivery_recipient_name { "MyString" }
    customer { nil }
  end
end
