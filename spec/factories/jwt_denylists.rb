FactoryBot.define do
  factory :jwt_denylist do
    jti { "MyString" }
    exp { "2025-07-22 12:52:38" }
  end
end
