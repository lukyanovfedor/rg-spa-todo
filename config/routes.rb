Rails.application.routes.draw do
  root 'home#index'

  scope except: %i(new edit), shallow: true do
    resources :projects do
      resources :tasks do
        member do
          put 'sort'
          put 'toggle'
        end

        resources :comments do
          resources :attachments
        end
      end
    end
  end

  mount_devise_token_auth_for 'User', at: 'auth', controllers: {
    omniauth_callbacks: 'auth/omniauth_callbacks',
  }

  match '*unmatched_route.json', to: 'application#raise_not_found!', via: :all
end
