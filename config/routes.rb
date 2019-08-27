Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  get 'dashboard', to: 'pages#dashboard'

  resources :jobs, only: [:new, :create, :show]
  resources :candidates, only: [:index, :show]
end
