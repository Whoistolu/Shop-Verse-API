FactoryBot.define do
  factory :otp do
    code { "MyString" }
    expires_at { "2025-07-31 10:38:25" }
    user { nil }
  end
end
