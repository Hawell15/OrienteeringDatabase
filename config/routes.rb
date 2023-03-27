Rails.application.routes.draw do
  devise_for :users
  resources :results
  resources :runners
  resources :groups
  resources :competitions
  resources :clubs
  get 'home/index'
  post 'home/index'
  post 'home/aaa'
  get 'home/get_groups'
  get 'parser/wre_ids'
  get 'parser/wre_results'
  get 'parser/html_results'
  post 'parser/html_results'
  get 'parser/fos_results'
  # get 'home/wre_results_women'
  resources :categories
  root "home#index"


  get 'groups/get_competitions'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
