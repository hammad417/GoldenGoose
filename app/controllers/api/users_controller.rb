class Api::UsersController < ApplicationController

  before_filter :authenticate_user!, :except => [:oauth_login]

  api :GET, '/users/me', 'Get current user.'
  error :code => 401, :desc => "Unauthorized"
  error :code => 403, :desc => "Not Allowed"
  description "Returns the current logged in user."
  param :auth_token, String, :desc => 'The auth token.', :required => true
  example 'curl -i -H "Accept: application/json" -d "auth_token=xD365B5FGDJur6PLw89L" -X GET http://api.shopvizr.com/api/users/me'
  example '{"id":1,"firstname":"Suhail","lastname":"Khalil","nickname":"suhail.khalil","email":"sohail.khalil56@gmail.com","created_at":"2013-09-23T07:38:06Z","updated_at":"2013-09-24T14:54:13Z","authentication":[{"id":1,"provider":"facebook","provider_user_id":"1483306480","provider_token":"CAAHc7wwOzNQBABEG5ouyOwNxt9plig4USkcSX26JP4LcjvhmBo6CBCZAwQxpFoGEeYyFZANVKoVTMCIZBU3ZCwEPaZCuEZCxmXQwaHo0RmKGr5HnprZCZArZByViTHOZBIgdhHIFHPwAm3JMReQFhZBJDRTdm94zcm8ZAcmhd2rFFZC7NJm7F9ykkMGXRj9FJDHWnuYwZD"}]}'
  def me
    @user = current_user
  end

  api :POST, '/auth/oauth', 'Signin user through provider, Returns current user.'
  error :code => 401, :desc => "Unauthorized"
  error :code => 403, :desc => "Not Allowed, Provider Login error"
  description "Returns the current loggedin user."
  param :provider, String, :desc => 'The provider through which we are authenticating', :required => true
  param :provider_user_id, String, :desc => 'The provider id or username through which we are authenticating', :required => true
  param :provider_token, String, :desc => 'The provider token through which we are authenticating', :required => true
  example 'curl -i -H "Accept: application/json" -d "provider={provider}&provider_user_id={provider_user_id}&provider_token={provider_token}" -X POST http://api.shopvizr.com/api/auth/oauth'
  example '{}'
  def oauth_login
    authentication = Authentication.where(:provider=>params[:provider],:provider_user_id=>params[:provider_user_id])
    unless authentication.blank?
      user = authentication.user
      sign_in user
      if current_user
        current_user.reset_authentication_token!

        @user = current_user

        render :json => {"auth_token"=> @user.authentication_token,"expires_in" => "3600", "user" => @user.as_json}, :status => 200
      else
        render :json => {}.as_json, :status => 403
      end
    else
      render :json => "No record found", :status => 404
    end
  end

  def build_omniauth_hash(profile)
    u = User.where(:email => profile['email']).first
    if u.nil?
      u = User.new
      u.email = profile['email']

      tmppwtoken = Devise.friendly_token[0,20]
      u.password = tmppwtoken
      u.password_confirmation = tmppwtoken
      u.nickname = profile['username'] ? profile['username'] : profile['first_name'] << "." << profile['last_name']
      u.firstname = profile['first_name']
      u.lastname = profile['last_name']
      u.save!
    end
    u
  end

  api :GET, '/users/search', 'Get users object array with matching email.'
  error :code => 401, :desc => "Unauthorized"
  error :code => 403, :desc => "Not Allowed"
  description "Returns users object array with matching email."
  param :auth_token, String, :desc => 'The auth token.', :required => true
  param :email_address, String, :desc => 'The email address to search.', :required => true
  example 'curl -i -H "Accept: application/json" -d "auth_token=5g4HrByw8fnunB8jFJq7&email_address=sohail.khalil56@gmail.com" -X GET http://api.shopvizr.com/api/users/search'
  example '{"users":[{"created_at":"2013-09-23T07:38:06Z","email":"sohail.khalil56@gmail.com","firstname":"Suhail","id":1,"lastname":"Khalil","nickname":"suhail.khalil","updated_at":"2013-09-24T14:46:20Z"}]}'
  def search
    email_address = params[:email_address]
    if email_address.split("").last == "*"
      email_address.chop!
      users = User.where("email LIKE ?", "#{email_address}%") unless email_address.empty?
    else
      users = User.find_all_by_email(params[:email_address])
    end
    render :json => {"users" => users.as_json}, :status => 200
  end

  api :POST, '/users/:user_id/add_email', 'Inserts users email.'
  error :code => 200, :desc => "Successfully added"
  error :code => 409, :desc => "Conflict, email already present"
  description "Add users email. If already taken then shows conflict error"
  param :auth_token, String, :desc => 'The auth token.', :required => true
  param :email_address, String, :desc => 'The email address to insert.', :required => true
  example 'curl -i -H "Accept: application/json" -d "auth_token=5g4HrByw8fnunB8jFJq7&email_address=sk@gmail.com" -X POST http://api.shopvizr.com/api/users/1/add_email'
  example '{"@email":{"address":"sk@gmail.com","created_at":"2013-09-24T14:43:11Z","id":10,"updated_at":"2013-09-24T14:43:11Z","user_id":1}}'
  def add_email
    @email = EmailAddress.new :address => params[:email_address], :user_id => current_user.id
    if @email.save
      render :json => {"@email" => @email.as_json}, :status => 200
    else
      render :json => {"error" => @email.errors.as_json}, :status => 409
    end
  end

end
