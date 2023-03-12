Rails.application.routes.draw do
  devise_for :users
  resources :results
  resources :runners
  resources :groups
  resources :competitions
  resources :clubs
  get 'home/index'
  get 'home/get_groups'
  resources :categories
  root "home#index"

  get 'groups/get_competitions'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
