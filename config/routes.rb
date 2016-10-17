Rails.application.routes.draw do

  devise_for :users

  get '/dashboard', to: 'users#dashboard'
  root to: 'pages#welcome'

end
