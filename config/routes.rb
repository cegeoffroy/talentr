Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth' }
  root to: 'pages#home'
  get 'dashboard', to: 'users#dashboard'

  resources :jobs, only: [:new, :create, :show]
  resources :candidates, only: [:index, :show]
end
