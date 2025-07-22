class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.decimal :total_price
      t.integer :status
      t.text :delivery_address
      t.string :delivery_phone_number
      t.string :delivery_recipient_name
      t.references :customer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
