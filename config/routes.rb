Rails.application.routes.draw do
  root 'static_pages#top'

  get '/login', to: "sessions#new"
  get '/auth/line', to: "sessions#create_line"
  post '/login/line', to: "sessions#line_login"
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  post '/gest_login', to: 'static_pages#gest_login'
  post '/email_login', to: 'sessions#create_email'
  delete '/logout', to: 'sessions#destroy'

  get "/intro", to: "static_pages#intro"

  resources :users do
    member do
      post "/send_mail", to: "users#send_mail"
    end
    resources :tasks, only: [:new, :create, :update, :destroy]
  end

end
