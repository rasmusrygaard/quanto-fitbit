Fitbit::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  get "/auth/quanto/:provider/callback" => "quanto_key#create"

  get "/auth/facebook/callback" => "facebook_key#create"
  get "/auth/fitbit/callback" => "fitbit_key#create"
  get "/auth/instagram/callback" => "instagram_key#create"
  get "/auth/lastfm/callback" => "lastfm_key#create"
  get "/auth/manual/callback" => "manual_key#create"
  get "/auth/moves/callback" => "moves_key#create"
  get "/auth/twitter/callback" => "twitter_key#create"

  resources :instagram_subscription, only: [:create, :index]
  resources :fitbit_subscription, only: [:create]

  post "/auth/manual" => "manual_input#authenticate"

  # Plugin POST endpoints. Allow POST /manual for instance
  resources :manual_input, only: [:create]
  get "/manual_input/metrics" => "manual_input#metrics"

  resources :fitbit, only: [:create]

  get '/ping' => 'ping#ping'
end
