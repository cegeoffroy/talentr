Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  get 'dashboard', to: 'users#dashboard'

  resources :jobs, only: [:new, :create, :show]
end
