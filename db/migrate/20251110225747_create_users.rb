class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :password_digest
      t.string :phone
      t.integer :role
      t.integer :status
      t.datetime :email_verified_at
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end
end
