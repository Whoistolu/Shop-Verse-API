class RemoveNameFromCustomers < ActiveRecord::Migration[7.1]
  def change
    remove_column :customers, :name, :string
  end
end
