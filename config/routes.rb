Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :logs
  root 'static#welcome'
  resources :greetings
  resources :users
  get 'temperature' => 'twilio#temperature'
  get 'sms' => 'twilio#sms'
  # these routes are for showing users a login form, logging them in, and logging them out.
  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  get '/logout' => 'sessions#destroy'

  get '/signup' => 'users#new'
  post '/users' => 'users#create'
  get '/images/gate.jpg' => 'twilio#gatecam_proxy'
end
