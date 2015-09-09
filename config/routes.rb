Rails.application.routes.draw do
  root 'home#index'
  mount_devise_token_auth_for 'User', at: 'auth'

  resources :projects, only: %i(create update destroy index)
end
