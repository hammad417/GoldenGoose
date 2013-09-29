class CreateReceipts < ActiveRecord::Migration
  def change
    create_table :receipts do |t|
      t.integer :user_id
      t.integer :store_id
      t.integer :store_location_id
      t.attachment :image

      t.timestamps
    end
  end
end
