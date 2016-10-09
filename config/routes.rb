Rails.application.routes.draw do
  root to: 'home#index'
  get 'users/index', to: 'users#index'
  devise_for :users
  resources :meters
  resources :schools
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
