Rails.application.routes.draw do

  devise_for :users

  authenticated :user do
    root 'domains/domains#index', as: :authenticated_root
  end

  root to: 'pages#welcome'

  scope module: 'domains' do
    resources :domains do
    resources :emails, shallow: true 
    end
  end

end
