class CreateDeliveryAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :delivery_addresses do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.string :phone_number
      t.text :description
      t.boolean :is_default

      t.timestamps
    end
  end
end
