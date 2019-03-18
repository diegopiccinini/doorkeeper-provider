Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  use_doorkeeper

  root 'welcome#index'
  get '/welcome/search' => "welcome#search"

  post '/tokensignin' => "google_sign_in#tokensignin"

  namespace :api do
    namespace :v1 do
      get '/me' => "credentials#me"
      post '/keys' => "credentials#keys"
      get '/enabled' => "oauth_applications#index"
      get '/show/:uid' => "oauth_applications#show"
      get '/find_by_external_id/:external_id' => "oauth_applications#find_by_external_id"
      put '/update/:uid' => "oauth_applications#update"
      post '/create' => "oauth_applications#create"
      get '/variable/:variable_name' => "oauth_applications#variable"
      post '/save_variable/:variable_name' => "oauth_applications#save_variable"
    end
  end

end
