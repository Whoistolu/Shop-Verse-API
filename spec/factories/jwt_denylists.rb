FactoryBot.define do
  factory :jwt_denylist do
    jti { "MyString" }
    exp { "2025-12-15 23:56:45" }
  end
end
