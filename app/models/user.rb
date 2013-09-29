class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable, :omniauthable, :omniauth_providers => [:facebook, :google_oauth2]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :firstname, :lastname, :nickname
  # attr_accessible :title, :body

  has_many :email_addresses, :dependent => :destroy
  has_many :authentications, :dependent => :destroy

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    authentication = Authentication.where(:provider => auth.provider, :provider_user_id => auth.uid).first
    user = User.find_by_email(auth.info.email)
    if user
      authentication= Authentication.create(:provider=>auth.provider,:provider_user_id=> auth.uid, :provider_token => auth.credentials.token, :user_id => user.id)
    end
    unless authentication
      user = User.new(firstname:auth.extra.raw_info.first_name,
                          lastname:auth.extra.raw_info.last_name,
                           email:auth.info.email,
                           nickname:auth.info.nickname,
                           password:Devise.friendly_token[0,20]
                           )
      unless user.save
        return nil
      else
        authentication= Authentication.create(:provider=>auth.provider,:provider_user_id=> auth.uid, :provider_token => auth.credentials.token, :user_id => user.id)
      end
    end
    authentication.provider_token = auth.credentials.token
    authentication.save
    authentication.user
  end

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    authentication = Authentication.where(:provider => access_token.provider, :provider_user_id => access_token.uid).first
    data = access_token.info
    user = User.find_by_email(data["email"])
    if user
      authentication= Authentication.create(:provider=>access_token.provider,:provider_user_id=> access_token.uid, :provider_token => access_token.credentials.token, :user_id => user.id)
    end
    unless authentication
      user = User.new(firstname:data["first_name"],
                          lastname:data["last_name"],
                           email:data["email"],
                           nickname:access_token.uid,
                           password:Devise.friendly_token[0,20]
                           )
      unless user.save
        return nil
      else
        authentication= Authentication.create(:provider=>access_token.provider,:provider_user_id=> access_token.uid, :provider_token => access_token.credentials.token, :user_id => user.id)
      end
    end
    authentication.provider_token = access_token.credentials.token
    authentication.save
    authentication.user
  end

end
