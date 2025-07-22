class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.decimal :price
      t.integer :stock
      t.integer :status
      t.string :image_url
      t.references :category, null: false, foreign_key: true
      t.references :brand, null: false, foreign_key: true

      t.timestamps
    end
  end
end
