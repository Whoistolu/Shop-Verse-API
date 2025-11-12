class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false, index: { unique: true }
      t.string :password_digest, null: false
      t.string :status, null: false, default: "pending"
      t.references :user_role, null: false, foreign_key: true

      t.timestamps
    end
  end
end
