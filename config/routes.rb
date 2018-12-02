Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'workouts#index'

  resources :logs, only: [:show]

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
    end
  end

  resource :schedule, only: [:show]
end
