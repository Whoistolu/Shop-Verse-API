class RemoveNameFromCustomers < ActiveRecord::Migration[8.0]
  def change
    remove_column :customers, :name, :string
  end
end
