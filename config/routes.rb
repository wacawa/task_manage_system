Rails.application.routes.draw do
  root 'static_pages#top'

  get '/login', to: "sessions#new"
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  post '/gest_login', to: 'static_pages#gest_login'
  post '/email_login', to: 'sessions#create_email'
  get '/logout', to: 'sessions#destroy'

  resources :users, except: [:new, :create]

end
