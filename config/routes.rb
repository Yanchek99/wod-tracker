Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  devise_for :users

  root to: 'workouts#index'

  resources :logs, only: [:show, :destroy]

  resources :movements, only: [:index, :create]

  resources :users do
    resources :movement_logs, only: [:personal_records] do
      collection do
        get :personal_records
      end
    end
  end

  resources :workouts do
    resources :logs
  end

  resources :programs do
    member do
      post :subscribe
      delete :unsubscribe
    end
  end

  resources :schedules, only: [:index, :create]
end
