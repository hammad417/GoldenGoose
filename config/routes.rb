Api::Application.routes.draw do

  apipie

  devise_for :users, :controllers => {:registrations => "api/registrations", :omniauth_callbacks => "api/omniauth_callbacks"}

  root :to => 'api/v1#index'

  devise_scope :user do
    post 'auth/oauth' => 'api/users#oauth_login'
  end
  get 'dashboard' => 'home#index'
  get 'users/me' => 'api/users#me', :defaults => { :format => 'json' }
  get 'users/search' => 'api/users#search', :defaults => { :format => 'json' }
  post 'users/:user_id/add_email' => 'api/users#add_email', :as => 'add_email', :defaults => { :format => 'json' }

  post 'users/:user_id/recepits/upload_receipt_image' => 'receipts#upload_receipt_image', :as => 'upload_receipt_image', :defaults => { :format => 'json' }

end
