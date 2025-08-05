class ChangeUserStatusToString < ActiveRecord::Migration[8.0]
  def up
    change_column :users, :status, :string
  end

  def down
    change_column :users, :status, :integer
  end
end
