Rails.application.routes.draw do
  root 'home#index'

  mount_devise_token_auth_for 'User', at: 'auth', controllers: {
    omniauth_callbacks: 'auth/omniauth_callbacks',
  }

  scope except: %i(new edit), shallow: true do
    resources :projects, except: :show  do
      resources :tasks do
        member do
          put 'toggle'
        end

        resources :comments, except: :show do
          resources :attachments, only: :destroy
        end
      end
    end
  end
end
