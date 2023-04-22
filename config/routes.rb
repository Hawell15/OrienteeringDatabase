Rails.application.routes.draw do
  get 'runners/test_modal'
  get 'runners/compare', as: "compare"
  post 'runners/compare', as: "compare_post"
  get 'clubs/add_admin/:id', to: 'clubs#add_admin', as: 'add_admin'
  post 'clubs/add_admin/:id', to: 'clubs#add_admin', as: 'add_admin_post'
  patch 'users/:id/remove', to: 'clubs#destroy_user', as: 'remove_user'

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
  get 'parser', to: 'parser#index', as: 'parser'
  get 'parser/wre_ids', as: 'wre_ids'
  get 'parser/wre_results', as: 'wre_results'
  get 'parser/html_results', as: 'html_results'
  post 'parser/html_results'
  get 'parser/excel_results', as: 'excel_results'
  post 'parser/excel_results', as: 'excel_results_post'
  post 'groups/count_rang', as: 'count_rang'
  get 'parser/fos_results', as: 'fos_results'
  get 'categories/count_categories'

  # get 'home/wre_results_women'
  resources :categories
  root "home#index"


  get 'groups/get_competitions'
  get "home/suggestions" => "home#suggestions"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
