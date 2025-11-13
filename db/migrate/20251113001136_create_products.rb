class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description
      t.references :brand, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.decimal :price, null: false, precision: 10, scale: 2
      t.integer :stock, null: false, default: 0
      t.string :status, null: false, default: "unpublished"
      t.string :image_url

      t.timestamps
    end
  end
end
