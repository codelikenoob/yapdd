Rails.application.routes.draw do
  get 'users/profile'

  devise_for :users
  root to: 'pages#welcome' 
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
