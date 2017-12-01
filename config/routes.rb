Rails.application.routes.draw do

  # Public resources
  root to: 'visitors#index'
  get '/lang/:lang', to: 'application#change_language', as: 'change_language'
  get '/show/:id', to: 'visitors#show', as: 'show'
  get '/update_holders', to: 'visitors#update_holders', as: 'update_holders'
  get '/inicio.do', to: 'uweb_access#uweb_sign_in'
  get '/agenda/:holder/:full_name', to: 'visitors#agenda', as: 'agenda'
  get '/import', to: 'users#import', as: 'import'
  get '/faq', to: 'questions#index', as: 'faq'
  resources :organizations, only: [:index, :show]

  # Static pages
  scope module: 'static_pages' do
    get '/rules', to: :rules
    get '/about_lobbies', to: :about_lobbies
    get '/code_of_conduct', to: :code_of_conduct
    get '/data_protection', to: :data_protection
    get '/regulatory_and_documentation', to: :regulatory_and_documentation
  end

  # Admin
  get "/admin", to: 'events#index', as: 'admin'

  devise_for :users, controllers: { session: "users/sessions" }
  get 'admin/edit_password', to: 'admin/passwords#edit', as: 'edit_password'
  match 'admin/update_password', to: 'admin/passwords#update', as: 'update_password', via: [:patch, :put]

  resources :users

  resources :events

  resources :holders

  resources :areas

  resources :activities

  namespace :admin do
    resources :organizations
    resources :questions
    post 'order_questions', to: 'questions#order', as: 'order_questions'
  end

end
