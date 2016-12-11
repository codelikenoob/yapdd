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
  get 'change_block_status/:id', to: "domains/emails#change_block_status", as: 'change_block_status'
  get 'change_domain/:id', to: "domains/domains#change_domain", as: 'change_domain'
  get 'set_current_email/:id', to: "domains/emails#set_current_email", as: 'set_current_email'
  get 'change_tab/:id', to: "domains/domains#change_tab", as: 'change_tab'
  get 'kill_filter/:id', to: "domains/emails#kill_filter", as: 'kill_filter'
  get 'email/new', to: "domains/emails#new"
  
end
