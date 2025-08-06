class AddUsedToOtps < ActiveRecord::Migration[7.1]
  def change
    add_column :otps, :used, :boolean, default: false
  end
end
