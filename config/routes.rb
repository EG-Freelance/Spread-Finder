Rails.application.routes.draw do
  devise_for :users
  root 'queries#index'

  get '/queries/rm/:sym' => 'queries#remove', :as => "remove_sym"
  post '/queries/add/' => 'queries#add', :as => "add_sym"
  resources :queries
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
