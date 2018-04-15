Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'workouts#index'

  resources :workouts do
    resources :logs
  end

  resources :users do
    resources :movement_logs, only: [:personal_records] do
      collection do
        get :personal_records
      end
    end
  end
end
