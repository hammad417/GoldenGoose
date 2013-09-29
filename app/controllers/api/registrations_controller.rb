class Api::RegistrationsController < Devise::RegistrationsController

  #resource_description do
  #  short 'Represents a user registration.'
  #end

  #api :POST, '/users', 'Create a new user.'
  #error 401, :desc => 'Invalid api key.'
  #description "Locate the user with lat and long."
  #param :api_key, String, :desc => 'The api_key. Defaults to api-registration.', :required => true
  #param :user, Hash, :desc => 'The new users user data.' do
  #  param :nickname, String, :desc => 'The users nick name.', :required => true
  #  param :firstname, String, :desc => 'The users first name.'
  #  param :lastname, String, :desc => 'The users last name.'
  #  param :email, String, :desc => 'The users email address.', :required => true
  #end
  #example 'curl -i -H "Accept: application/json" -d "api_key=api-registration&user[email]=test@email.com&user[nickname]=testuser" -X POST http://localhost:3000/api/users'
  #example '{"error":"Username has already been taken\nEmail is already in use\n"}'
  #example 'curl -i -H "Accept: application/json" -d "api_key=api-registration&user[email]=test2@email.com&user[nickname]=testuser2" -X POST http://localhost:3000/api/users'
  #example '{"auth_token":"PqxSszXFskjZDAssfxL6","expires_in":"3600","user":"{\"created_at\":\"2013-09-17T13:45:26Z\",\"email\":\"test2@email.com\",\"firstname\":null,\"id\":3,\"lastname\":null,\"nickname\":\"testuser2\",\"updated_at\":\"2013-09-17T13:45:28Z\"}"}'
  def create
    respond_to do |format|
      format.json{
        if params[:api_key].blank? or params[:api_key] != API_KEY
          render :json => {'errors'=>{'api_key' => 'Invalid'}}.as_json, :status => 401
          return
        end

        require 'securerandom'
        newPassword = SecureRandom.hex(4)
        params[:user]["password"] = newPassword
        params[:user]["password_confirmation"] = newPassword

        build_resource

        resource = User.new(params[:user])

        debugger

        if resource.save
          UserMailer.password_reset(resource, newPassword).deliver

          resource.reset_authentication_token!
          render :json => {"auth_token"=> resource.authentication_token,"expires_in" => "3600", "user" => resource.as_json}, :status => 200
        else
          p resource.errors.messages

          error_message = ""
          i = 0

          e = resource.errors.messages[:nickname]
          if e
            0.upto(e.length - 1) do |m|
              error_message = error_message + "Nickname " + e[m] + "\n"
              i += 1
            end
          end

          e = resource.errors.messages[:email]
          if e
            0.upto(0) do |m|
              error_message = error_message + "Email " + e[m] + "\n"
              i += 1
            end
          end

          e = resource.errors.messages[:password]
          if e
            0.upto(e.length - 1) do |m|
              error_message = error_message + "Passwort " + e[m] + "\n"
              i += 1
            end
          end

          if i == 0
            error_message = "There was an error."
          end
          
          render :json => {'error'=>error_message}.as_json, :status => 403

        end
      }
    end
  end

end
