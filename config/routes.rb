Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth' }
  authenticated :user do
    root :to => "users#dashboard"
  end
  root to: 'pages#home'
  get 'dashboard', to: 'users#dashboard'


  resources :jobs, only: [:index, :new, :create, :show] do
    get 'filter', to: 'jobs#filter'
    get 'remove_filter', to: 'jobs#remove_filter'
    resources :job_applications, only: [:new, :create]
  end

  resources :job_applications, only: :update

  resources :candidates, only: [:new, :index, :show]
  namespace :charts do
    get 'new_candidates'
  end
  resources :users, only: [:show, :update]
end
