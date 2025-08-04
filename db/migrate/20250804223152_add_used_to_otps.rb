class AddUsedToOtps < ActiveRecord::Migration[8.0]
  def change
    add_column :otps, :used, :boolean
  end
end
