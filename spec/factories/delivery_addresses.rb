FactoryBot.define do
  factory :delivery_address do
    phone_number { "MyString" }
    description { "MyText" }
    first_name { "MyString" }
    last_name { "MyString" }
    customer { nil }
    is_default { false }
  end
end
