Rails.application.routes.draw do
  root 'home#index'
  mount_devise_token_auth_for 'User', at: 'auth'

  resources :projects, except: %i(new edit) do
    resources :tasks, except: %i(new edit), shallow: true do
      member do
        put 'toggle'
      end

      resources :comments, except: %i(new edit), shallow: true
    end
  end
end
