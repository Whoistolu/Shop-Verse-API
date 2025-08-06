class ChangeStatusToIntegerInUsers < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      ALTER TABLE users
      ALTER COLUMN status TYPE integer USING CAST(status AS integer),
      ALTER COLUMN status SET DEFAULT 0,
      ALTER COLUMN status SET NOT NULL;
    SQL
  end

  def down
    change_column :users, :status, :string
  end
end
