class CreateAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.integer :user_id
      t.string :provider
      t.string :provider_id
      t.text :provider_token

      t.timestamps
    end
  end
end
