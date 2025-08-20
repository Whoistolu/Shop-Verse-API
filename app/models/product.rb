class Product < ApplicationRecord
  belongs_to :category
  belongs_to :brand


  validates :name, :description, :price, :stock, :status, :image_url, :category_id, :brand_id, presence: true
  validates :category_id, presence: true
  validate :category_must_be_globalbefore_validation :set_default_status, on: :create

  def category_must_be_global
    unless Category.exists?(id: category_id)
      errors.add(:category_id, "must be valid")
    end
  end

  enum status: { published: 0, unpublished: 1 }

  private

  def set_default_status
    self.status ||= :unpublished
  end
end
