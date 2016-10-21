Rails.application.routes.draw do

  devise_for :users

  authenticated :user do
    root 'domains/domains#dashboard', as: :authenticated_root
  end

  root to: 'pages#welcome'

  scope module: 'domains' do
    resources :domains do
    resources :emails, shallow: true 
    end
  end

  get 'refresh/:id', to: "domains/domains#refresh", as: 'refresh_domain'
  get 'get_inside_mail/:id', to: "domains/emails#get_inside_mail", as: 'get_inside_mail'

  
end
