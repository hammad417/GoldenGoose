class Api::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  api :POST, '/users/auth/facebook/callback', 'Signin/Signup user through facebook, Returns current user.'
  error :code => 403, :desc => "Not Allowed, Provider Login error"
  description "Signin/Sign up current user and redirects tp /api/users/me which returns json reponse of user node and its all authentications in array"
  param :code, String, :desc => 'The provider callback code returned', :required => true
  example 'curl -i -H "Accept: application/json" -d "code=AQBYK5g-XiA1-vZN_7kfZZgUYBTr__OVh6tFOPctuPtKd2bavnWfYMuyVJ8L1lsRWHOMYOXmCp63RJM3_ARIKKXtOWsZKS3ZlcYhyBEQw03Bzzy6r8MXeQMOA-lfZ39Me2D3WVY1pGpSYEMhI41BbvvFjvdL-AdyfGk7JWI72jzHv-M6cp29-s9tIUTFQB80r3xQmNyTLmua9Pbrj1TjrP1UjVaeF5cQWngrbaqWYkw4EVoU9dn3th8JWp4IQ40NBw62hg_wP1n3dkE2S4-7T5mjl1RCtb15TC1HbgFJSIAmpcHaFxFH0k8E7Nkapy6iRCg&state=ac735a982485164c8f30a115c0845a959d2df4830447d6cd" -X POST http://api.shopvizr.com/api/users/auth/facebook/callback'
  def facebook
    @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)
    if @user.persisted?
      sign_in @user, :event => :authentication
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
      if current_user
        current_user.reset_authentication_token!

        @user = current_user
        return redirect_to "/api/dashboard"
      end
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      return redirect_to new_user_registration_url
    end
  end

  api :POST, '/users/auth/google_oauth2/callback', 'Signin/Signup user through google, Returns current user.'
  error :code => 403, :desc => "Not Allowed, Provider Login error"
  description "Signin/Sign up current user and redirects tp /api/users/me which returns json reponse of user node and its all authentications in array"
  param :code, String, :desc => 'The provider callback code returned', :required => true
  example 'curl -i -H "Accept: application/json"  -X POST http://api.shopvizr.com/api/users/auth/google_oauth2/callback'
  def google_oauth2
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.find_for_google_oauth2(request.env["omniauth.auth"])
    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
      sign_in @user, :event => :authentication
      if current_user
        current_user.reset_authentication_token!

        @user = current_user
        return redirect_to "/api/dashboard"
      end
    else
      session["devise.google_data"] = request.env["omniauth.auth"]
      return redirect_to new_user_registration_url
    end
  end

end