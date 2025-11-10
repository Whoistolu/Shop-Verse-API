class CreateBrands < ActiveRecord::Migration[7.1]
  def change
    create_table :brands do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.string :business_email
      t.string :business_phone
      t.text :business_address
      t.string :logo_url
      t.string :website_url
      t.integer :status
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end
end
