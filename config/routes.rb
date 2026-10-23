Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  devise_for :users, controllers: { registrations: 'users/registrations' }
  devise_scope :user do
    post 'passkey_session/options', to: 'users/passkey_sessions#options', as: :options_passkey_session
    post 'passkey_session', to: 'users/passkey_sessions#create', as: :passkey_session
  end
  resources :passkeys, only: [:create, :destroy] do
    post :options, on: :collection
  end
  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest, defaults: { format: :json }

  authenticated :user do
    root to: 'schedules#index', as: :authenticated_root
  end
  root to: 'workouts#index'

  resources :logs, only: [:index, :show, :destroy]

  resources :movements, only: [:index, :create]

  resources :sugarwod_imports, only: [:new, :create, :show]

  resources :users do
    resources :personal_records, only: [:index] do
      collection do
        get ':family', to: 'personal_records#family', as: :family,
                       constraints: { family: /weightlifting|gymnastics|monostructural/ }
        get :repeated_workouts
      end
    end
  end

  resources :workouts do
    resources :logs, except: [:index]

    member do
      get :edit_unstructured
      patch :re_extract
    end

    collection do
      post :extract
      get :new_unstructured
    end
  end

  resources :programs do
    member do
      post :subscribe
      delete :unsubscribe
    end
    resources :schedules, only: [:new, :create]
  end

  resources :schedules, only: [:index, :create]
end
