class CreateDeliveryAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :delivery_addresses do |t|
      t.string :phone_number
      t.text :description
      t.string :first_name
      t.string :last_name
      t.references :customer, null: false, foreign_key: true
      t.boolean :is_default

      t.timestamps
    end
  end
end
