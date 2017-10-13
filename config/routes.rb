Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  use_doorkeeper

  root 'welcome#index'
  get '/welcome/search' => "welcome#search"

  namespace :api do
    namespace :v1 do
      get '/me' => "credentials#me"
      post '/keys' => "credentials#keys"
      get '/enabled' => "oauth_applications#index"
    end
  end

end
