class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :customer, null: false, foreign_key: true
      t.decimal :total_price, null: false, precision: 10, scale: 2
      t.string :status, null: false, default: "pending"
      t.string :delivery_address, null: false
      t.string :delivery_phone_number, null: false
      t.string :delivery_recipient_name, null: false

      t.timestamps
    end
  end
end
