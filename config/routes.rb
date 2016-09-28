Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  use_doorkeeper

  root 'welcome#index'
  namespace :api do
    namespace :v1 do
      get '/me' => "credentials#me"
    end
  end

end
