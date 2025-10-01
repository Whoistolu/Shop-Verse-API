class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :first_name, :last_name, :user_role_id

  # Include token only when it's available (during login)
  attribute :token, if: -> { object.instance_variable_get(:@token).present? }

  def token
    object.instance_variable_get(:@token)
  end
end
