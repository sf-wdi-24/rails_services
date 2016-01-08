Rails.application.routes.draw do

  root "posts#index"
  resources :posts do
    resources :comments, except: [:index, :show]
    member do
      get "share"
      post "share"
    end
  end

  resources :users, except: [:new]

  get "/signup", to: "users#new"
  get "/login", to: "sessions#new"
  get "/logout", to: "sessions#destroy"
  resources :sessions, only: [:create]

end