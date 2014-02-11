Fitbit::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  get "/auth/quanto/:provider/callback" => "quanto_key#create"

  get "/auth/fitbit/callback" => "fitbit_key#create"
  get "/auth/lastfm/callback" => "lastfm_key#create"
  get "/auth/instagram/callback" => "instagram_key#create"

  # Plugin POST endpoints. Allow POST /manual for instance
  resources :manual_input, only: [:create]
  resources :fitbit, only: [:create]

  get '/ping' => 'ping#ping'
end
