class RenameProviderIdToProviderUserId < ActiveRecord::Migration

  def change
    rename_column :authentications, :provider_id, :provider_user_id
  end

end
