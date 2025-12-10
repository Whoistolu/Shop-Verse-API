FactoryBot.define do
  factory :delivery_address do
    customer { nil }
    first_name { "MyString" }
    last_name { "MyString" }
    phone_number { "MyString" }
    description { "MyText" }
    is_default { false }
  end
end
