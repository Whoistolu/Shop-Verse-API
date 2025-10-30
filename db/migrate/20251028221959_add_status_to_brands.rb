class AddStatusToBrands < ActiveRecord::Migration[7.1]
  def change
    add_column :brands, :status, :integer, default: 0, null: false
    add_column :brands, :activated_at, :datetime
    add_column :brands, :deactivated_at, :datetime
    add_column :brands, :status_changed_by_id, :integer
    
    add_index :brands, :status
    add_index :brands, :activated_at
    add_foreign_key :brands, :users, column: :status_changed_by_id
  end
end
