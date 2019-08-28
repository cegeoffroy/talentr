Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth' }
  root to: 'pages#home'
  get 'dashboard', to: 'users#dashboard'

  resources :jobs, only: [:new, :create, :show] do
    resources :job_applications, only: :create
  end
  resources :candidates, only: [:index, :show]
end
