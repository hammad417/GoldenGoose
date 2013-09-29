class Authentication < ActiveRecord::Base

  belongs_to :user

  attr_accessible :provider, :provider_user_id, :provider_token, :user_id
end
