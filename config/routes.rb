Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  devise_for :users, controllers: { registrations: 'users/registrations' }
  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest, defaults: { format: :json }

  root to: 'workouts#index'

  resources :logs, only: [:index, :show, :destroy]

  resources :movements, only: [:index, :create]

  resources :users do
    resources :personal_records, only: [:index] do
      collection do
        get :lifts
        get :barbell
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
  end

  resources :schedules, only: [:index, :create]
end
