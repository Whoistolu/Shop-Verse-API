class Otp < ApplicationRecord
  belongs_to :user

  validates :code, presence: true, uniqueness: true
  validates :expires_at, presence: true

  def expired?
    Time.current > expires_at
  end

  def mark_as_used
    update!(used: true)
  end
end
