Rails.application.routes.draw do
  devise_for :users
  root 'listings#index'

  authenticated do
    get '/charts' => 'listings#charts', :as => "charts"
    get '/tables' => 'listings#tables', :as => "tables"
    get '/listings/rm/:sym' => 'listings#remove', :as => "remove_sym"
    patch '/ujs/update_data/:sym' => 'listings#update_data', :as => "update_data"
    post '/listings/add/' => 'listings#add', :as => "add_sym"
    resources :listings
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
