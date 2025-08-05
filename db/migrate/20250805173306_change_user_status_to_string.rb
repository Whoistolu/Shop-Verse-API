class ChangeUserStatusToString < ActiveRecord::Migration[7.1]
  def up
    change_column :users, :status, :string
  end

  def down
    change_column :users, :status, :integer
  end
end
