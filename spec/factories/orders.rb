FactoryBot.define do
  factory :order do
    customer { nil }
    total_price { "9.99" }
    status { "MyString" }
    delivery_address { "MyString" }
    delivery_phone_number { "MyString" }
    delivery_recipient_name { "MyString" }
  end
end
