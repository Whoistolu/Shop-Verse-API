class RemoveCustomerIdFromDeliveryAddresses < ActiveRecord::Migration[7.1]
  def change
    remove_reference :delivery_addresses, :customer, null: false, foreign_key: true
  end
end
