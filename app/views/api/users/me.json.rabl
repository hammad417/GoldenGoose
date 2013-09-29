object @user
attributes :id, :firstname, :lastname, :nickname, :email, :created_at, :updated_at

child :authentications  => :authentication do
  attributes :id, :provider, :provider_user_id, :provider_token
end