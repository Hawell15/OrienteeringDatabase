Rails.application.routes.draw do
  devise_for :users
  resources :results
  resources :runners
  resources :groups
  resources :competitions
  resources :clubs
  get 'home/index'
  resources :categories
  root "home#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
